import 'dart:convert';

import 'package:interna/config/api_client.dart';
import 'package:interna/features/profile/data/student_profile.model.dart';

class StudentRepository {


  static StudentProfile? _cachedProfile;

  /// In-memory cached student profile
  static StudentProfile? get cachedProfile => _cachedProfile;

  static void setCachedProfile(StudentProfile? profile) {
    _cachedProfile = profile;
  }

  static Future<StudentProfile?> getMyProfile({bool force = false}) async {
    if (!force && _cachedProfile != null) {
      // Return cached immediately and refresh in background
      _fetchAndCache();
      return _cachedProfile;
    }
    return _fetchAndCache();
  }

  static Future<StudentProfile?> _fetchAndCache() async {
    final response = await ApiClient.get('/student/profile/me');
    if (response.statusCode == 404) {
      _cachedProfile = null;
      return null;
    }
    if (response.statusCode != 200) {
      throw Exception("Failed To Load Profile: ${response.statusCode}");
    }

    final date = jsonDecode(response.body);
    final profile = StudentProfile.fromJson(date as Map<String, dynamic>);
    _cachedProfile = profile;
    return profile;
  }

  static Future<StudentProfile> createProfile(Map<String, dynamic> body) async {
    final response = await ApiClient.post('/student/profile', body);
    if (response.statusCode != 201) {
      throw Exception("Failed to create Profile ${response.statusCode}");
    }
    final profile = StudentProfile.fromJson(jsonDecode(response.body));
    _cachedProfile = profile;
    return profile;
  }

  static Future<StudentProfile> updateProfile(Map<String, dynamic> body) async {
    final response = await ApiClient.patch('/student/profile', body);
    if (response.statusCode != 200) {
      throw Exception("Failed to Update Profile ${response.statusCode}");
    }
    final profile = StudentProfile.fromJson(jsonDecode(response.body));
    _cachedProfile = profile;
    return profile;
  }

  static Future<void> deleteStudentProfile() async {
    final response = await ApiClient.delete('/student/profile');
    if (response.statusCode != 200) {
      throw Exception("Failed To Delete Profile ${response.statusCode}");
    }
    _cachedProfile = null;
  }


}