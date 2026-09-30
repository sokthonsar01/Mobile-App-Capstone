import 'dart:convert';
import '../../../config/api_client.dart';

class ResumeItem {
  final String id;
  final String studentId;
  final String fileUrl;
  final bool isDefault;

  const ResumeItem({
    required this.id,
    required this.studentId,
    required this.fileUrl,
    required this.isDefault,
  });

  factory ResumeItem.fromJson(Map<String, dynamic> json) {
    return ResumeItem(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
    );
  }
}

class ResumeRepository {
  /// Fetch all resumes for the authenticated student
  static Future<List<ResumeItem>> getMyResumes() async {
    final response = await ApiClient.get('/resumes');
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body) as List? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(ResumeItem.fromJson)
          .toList();
    }
    return [];
  }

  /// Register or get a default resume for the student
  static Future<ResumeItem> getOrCreateDefaultResume() async {
    final existing = await getMyResumes();
    if (existing.isNotEmpty) {
      return existing.firstWhere(
        (r) => r.isDefault,
        orElse: () => existing.first,
      );
    }

    // Register a default resume if student has none
    final response = await ApiClient.post('/resumes', {
      'fileUrl':
          'https://fujimqtgrthnslpwjkqf.supabase.co/storage/v1/object/public/resumes/default_student_cv.pdf',
      'isDefault': true,
    });

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ResumeItem.fromJson(json);
    }

    throw Exception(
        'Failed to register default resume. HTTP ${response.statusCode}');
  }
}
