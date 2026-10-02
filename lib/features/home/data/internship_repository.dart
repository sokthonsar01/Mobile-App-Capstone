import 'dart:convert';
import '../../../config/api_client.dart';
import 'internship_model.dart';

/// Repository responsible for fetching and caching internship opportunities from the NestJS backend.
class InternshipRepository {
  /// Fetches paginated internship opportunities with optional keyword search.
  static Future<List<InternshipOpportunity>> getInternships({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final query = StringBuffer('/internships?page=$page&limit=$limit');
    if (search != null && search.trim().isNotEmpty) {
      query.write('&search=${Uri.encodeComponent(search.trim())}');
    }

    final response = await ApiClient.get(query.toString());

    if (response.statusCode != 200) {
      throw Exception('Failed to load internships: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final List items = data['data'] ?? [];
    return items
        .map((json) =>
            InternshipOpportunity.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single internship opportunity by ID with full details.
  static Future<InternshipOpportunity?> getInternshipById(String id) async {
    if (id.trim().isEmpty) return null;
    try {
      final response = await ApiClient.get('/internships/$id');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return InternshipOpportunity.fromJson(data);
      }
    } catch (_) {}
    return null;
  }
}

