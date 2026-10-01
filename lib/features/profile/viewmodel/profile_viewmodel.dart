import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../data/student_profile.model.dart';
import '../data/student_repository.dart';

/// ViewModel managing student profile state, persistence, and avatar updates.
class ProfileViewModel extends ChangeNotifier {
  static final ProfileViewModel instance = ProfileViewModel._internal();

  ProfileViewModel._internal();

  StudentProfile? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  String? _errorMessage;
  String? _successMessage;

  StudentProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isUploadingAvatar => _isUploadingAvatar;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Fetches the authenticated student's profile from the backend
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await StudentRepository.getMyProfile();
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves or updates the student profile
  Future<bool> saveProfile(Map<String, dynamic> data) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (_profile != null) {
        _profile = await StudentRepository.updateProfile(data);
      } else {
        _profile = await StudentRepository.createProfile(data);
      }
      _successMessage = 'Profile updated successfully!';
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save profile: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Uploads avatar binary to Supabase Storage 'avatars' bucket
  Future<String?> uploadAvatar({
    required Uint8List bytes,
    required String ext,
    required String userId,
  }) async {
    _isUploadingAvatar = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final contentType = ext == 'png'
          ? 'image/png'
          : (ext == 'webp' ? 'image/webp' : 'image/jpeg');
      final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      final storage = sb.Supabase.instance.client.storage.from('avatars');
      await storage.uploadBinary(
        fileName,
        bytes,
        fileOptions: sb.FileOptions(contentType: contentType, upsert: true),
      );

      final publicUrl = storage.getPublicUrl(fileName);

      // Persist to backend and Supabase metadata
      await saveProfile({'avatarUrl': publicUrl});
      try {
        await sb.Supabase.instance.client.auth.updateUser(
          sb.UserAttributes(data: {'avatar_url': publicUrl}),
        );
      } catch (_) {}

      return publicUrl;
    } catch (e) {
      _errorMessage = 'Avatar upload failed: $e';
      return null;
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }
}
