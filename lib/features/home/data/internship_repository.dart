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
}

