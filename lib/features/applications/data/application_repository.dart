import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_client.dart';
import 'application_tracker_store.dart';
import '../../home/data/internship_model.dart';

/// Clean API exception preserving backend status codes and validation messages
class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class ApplicationRepository {
  /// Extracts exact NestJS error message (handles both strings and validation arrays)
  static String _extractErrorMessage(http.Response response, String fallback) {
    try {
      final data = jsonDecode(response.body);
      final msg = data['message'];
      if (msg is List) return msg.join('\n');
      if (msg is String && msg.isNotEmpty) return msg;
    } catch (_) {}
    return fallback;
  }

  /// Submit application to backend with strong typing
  static Future<TrackedApplication> apply({
    required String internshipId,
    required String resumeId,
    String? coverLetter,
    String? portfolioLink,
  }) async {
    final response = await ApiClient.post('/applications', {
      'internshipId': internshipId,
      'resumeId': resumeId,
      if (coverLetter != null && coverLetter.isNotEmpty) 'coverLetter': coverLetter,
      if (portfolioLink != null && portfolioLink.isNotEmpty) 'portfolioLink': portfolioLink,
    });

    if (response.statusCode == 201) {
      final raw = jsonDecode(response.body) as Map<String, dynamic>;
      final rawInternship = raw['internship'] as Map<String, dynamic>? ?? {};
      final internship = InternshipOpportunity.fromJson(rawInternship);
      final appliedAt = raw['appliedAt'] != null
          ? DateTime.tryParse(raw['appliedAt'].toString())
          : null;
      final dateStr = appliedAt != null
          ? ApplicationTrackerStore.formatDateTime(appliedAt)
          : ApplicationTrackerStore.formatDateTime(DateTime.now());

      return TrackedApplication(
        id: raw['id']?.toString() ?? '',
        internship: internship,
        appliedDate: dateStr,
        deadline: internship.deadline,
        lastUpdated: dateStr,
        status: ApplicationTrackerStore.normalizeStatus(raw['status']?.toString()),
      );
    }

    throw ApiException(
      _extractErrorMessage(response, 'Failed to submit application.'),
      response.statusCode,
    );
  }

  /// Fetch typed student applications for tracker
  static Future<List<TrackedApplication>> getMyApplications() async {
    final response = await ApiClient.get('/applications/me');

    if (response.statusCode == 200) {
      final List rawList = jsonDecode(response.body) as List? ?? [];
      final List<TrackedApplication> items = [];

      for (final raw in rawList) {
        if (raw is! Map<String, dynamic>) continue;
        final rawInternship = raw['internship'] as Map<String, dynamic>?;
        if (rawInternship == null) continue;

        final internship = InternshipOpportunity.fromJson(rawInternship);
        final appliedAt = raw['appliedAt'] != null
            ? DateTime.tryParse(raw['appliedAt'].toString())
            : null;
        final dateStr = appliedAt != null
            ? ApplicationTrackerStore.formatDateTime(appliedAt)
            : ApplicationTrackerStore.formatDateTime(DateTime.now());

        items.add(
          TrackedApplication(
            id: raw['id']?.toString() ?? '',
            internship: internship,
            appliedDate: dateStr,
            deadline: internship.deadline,
            lastUpdated: dateStr,
            status: ApplicationTrackerStore.normalizeStatus(raw['status']?.toString()),
          ),
        );
      }
      return items;
    }

    throw ApiException(
      _extractErrorMessage(response, 'Failed to load applications.'),
      response.statusCode,
    );
  }

  /// Withdraw an active application (Accepts 200 OK or 204 No Content)
  static Future<void> withdraw(String applicationId) async {
    final response = await ApiClient.delete('/applications/$applicationId');

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw ApiException(
      _extractErrorMessage(response, 'Failed to withdraw application.'),
      response.statusCode,
    );
  }
}
