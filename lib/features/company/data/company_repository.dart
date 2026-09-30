import 'dart:convert';
import '../../../config/api_client.dart';
import 'company_model.dart';

/// Repository for handling company-related network requests to the NestJS backend.
class CompanyRepository {
  /// Fetches a paginated list of companies with optional keyword or industry search.
  static Future<List<Company>> getCompanies({
    int page = 1,
    int limit = 10,
    String? search,
    String? industry,
  }) async {
    final query = StringBuffer('/company?page=$page&limit=$limit');
    if (search != null && search.trim().isNotEmpty) {
      query.write('&search=${Uri.encodeComponent(search.trim())}');
    }
    if (industry != null && industry.trim().isNotEmpty) {
      query.write('&industry=${Uri.encodeComponent(industry.trim())}');
    }

    final response = await ApiClient.get(query.toString());

    if (response.statusCode != 200) {
      throw Exception('Failed to load companies: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final List items = data['data'] ?? [];
    return items
        .map((json) => Company.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches single company details by ID.
  static Future<Company> getCompanyById(String id) async {
    final response = await ApiClient.get('/company/$id');

    if (response.statusCode != 200) {
      throw Exception('Failed to load company $id: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return Company.fromJson(data as Map<String, dynamic>);
  }
}
