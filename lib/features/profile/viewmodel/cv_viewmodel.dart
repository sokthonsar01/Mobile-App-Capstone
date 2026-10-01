import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/resume_repository.dart';

/// ViewModel managing CV / Resume document state, Supabase storage uploads, and preview.
class CvViewModel extends ChangeNotifier {
  static final CvViewModel instance = CvViewModel._internal();

  CvViewModel._internal();

  ResumeItem? _currentResume;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;
  String? _successMessage;
  Uint8List? _localPdfBytes;

  ResumeItem? get currentResume => _currentResume;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasResume => _currentResume != null;
  Uint8List? get localPdfBytes => _localPdfBytes;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void resetToDefaults() {
    _currentResume = null;
    _isLoading = false;
    _isUploading = false;
    _errorMessage = null;
    _successMessage = null;
    _localPdfBytes = null;
    notifyListeners();
  }

  /// Load existing resume from backend or Supabase
  Future<void> loadMyResume() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await ResumeRepository.getMyResumes();
      if (list.isNotEmpty) {
        _currentResume = list.firstWhere(
          (r) => r.isDefault,
          orElse: () => list.first,
        );
      }
    } catch (_) {
      // Backend not available or offline fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Open file picker, upload selected PDF to Supabase Storage, and register with backend.
  Future<bool> pickAndUploadCv() async {
    if (_isUploading) return false;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'Please sign in to upload your CV.';
      notifyListeners();
      return false;
    }

    final PlatformFile? file;
    try {
      file = await FilePicker.pickFile(
        dialogTitle: 'Select your CV (PDF)',
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
    } catch (_) {
      _errorMessage = 'Could not open the file picker. Please try again.';
      notifyListeners();
      return false;
    }

    if (file == null) return false; // User cancelled

    _isUploading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // 1. Read bytes directly from PlatformFile
      final bytes = await file.readAsBytes();
      _localPdfBytes = bytes;

      // 2. Upload binary to Supabase Storage 'resumes' bucket
      final publicUrl = await ResumeRepository.uploadCvToSupabase(
        fileName: file.name,
        bytes: bytes,
        userId: userId,
      );

      // 3. Register or sync with backend API
      try {
        final savedItem = await ResumeRepository.createResume(
          fileUrl: publicUrl,
          fileName: file.name,
          fileSizeBytes: bytes.length,
          isDefault: true,
        );
        _currentResume = savedItem;
      } catch (_) {
        // If backend endpoint is temporarily offline, persist local Supabase reference
        _currentResume = ResumeItem(
          id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
          studentId: userId,
          fileUrl: publicUrl,
          fileName: file.name,
          fileSizeBytes: bytes.length,
          updatedAt: DateTime.now(),
          isDefault: true,
        );
      }

      _successMessage = 'CV uploaded successfully to Supabase!';
      return true;
    } on StorageException catch (e) {
      if (e.message.contains('Bucket not found') ||
          e.statusCode == '404' ||
          e.error == 'NoSuchBucket') {
        _errorMessage =
            "Storage bucket 'resumes' not found. Please create a public bucket named 'resumes' in your Supabase dashboard.";
      } else {
        _errorMessage = 'Supabase upload failed: ${e.message}';
      }
      return false;
    } catch (e) {
      _errorMessage = 'Upload failed: $e';
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
