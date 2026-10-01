import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/api_client.dart';
import 'resume_model.dart';

export 'resume_model.dart';

/// Repository for handling CV document upload to Supabase and backend synchronization.
class ResumeRepository {
  static const String _bucketName = 'resumes';

  /// Uploads PDF bytes to the Supabase Storage 'resumes' bucket and returns its public URL.
  static Future<String> uploadCvToSupabase({
    required String fileName,
    required Uint8List bytes,
    required String userId,
  }) async {
    final storage = Supabase.instance.client.storage.from(_bucketName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath = '$userId/${timestamp}_$cleanFileName';

    await storage.uploadBinary(
      storagePath,
      bytes,
      fileOptions: const FileOptions(
        contentType: 'application/pdf',
        upsert: true,
      ),
    );

    return storage.getPublicUrl(storagePath);
  }

  /// Fetch all resumes for the authenticated student from backend NestJS API
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

  /// Register or update a resume record on the backend
  static Future<ResumeItem> createResume({
    required String fileUrl,
    required String fileName,
    int? fileSizeBytes,
    bool isDefault = true,
  }) async {
    final response = await ApiClient.post('/resumes', {
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSizeBytes': ?fileSizeBytes,
      'isDefault': isDefault,
    });

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ResumeItem.fromJson(json);
    }

    throw Exception(
      'Failed to register resume with backend API. HTTP ${response.statusCode}',
    );
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
    return await createResume(
      fileUrl:
          'https://fujimqtgrthnslpwjkqf.supabase.co/storage/v1/object/public/resumes/default_student_cv.pdf',
      fileName: 'default_student_cv.pdf',
      isDefault: true,
    );
  }
}
