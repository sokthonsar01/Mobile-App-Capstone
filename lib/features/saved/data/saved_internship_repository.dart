import 'dart:convert';
import '../../../config/api_client.dart';
import '../../home/data/internship_model.dart';

class SavedInternshipRepository {
  /// Fetch all saved internships for the authenticated student from NestJS backend.
  static Future<List<InternshipOpportunity>> getSavedInternships() async {
    final response = await ApiClient.get('/internships/saved/me');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List list =
          decoded is List ? decoded : (decoded['data'] as List? ?? []);

      final List<InternshipOpportunity> fetched = [];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          if (item.containsKey('internship') &&
              item['internship'] is Map<String, dynamic>) {
            fetched.add(InternshipOpportunity.fromJson(
                item['internship'] as Map<String, dynamic>));
          } else {
            fetched.add(InternshipOpportunity.fromJson(item));
          }
        }
      }
      return fetched;
    }

    if (response.statusCode == 404 || response.statusCode == 401) {
      return [];
    }

    throw Exception('Failed to load saved internships: ${response.statusCode}');
  }

  /// Bookmark an internship in the backend.
  static Future<void> saveInternship(String id) async {
    final response = await ApiClient.post('/internships/$id/save', {});
    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      throw Exception('Failed to bookmark internship: ${response.statusCode}');
    }
  }

  /// Remove an internship from bookmarks in the backend.
  static Future<void> removeInternship(String id) async {
    final response = await ApiClient.delete('/internships/$id/save');
    if (response.statusCode != 200 &&
        response.statusCode != 204 &&
        response.statusCode != 404) {
      throw Exception(
          'Failed to remove bookmarked internship: ${response.statusCode}');
    }
  }
}
