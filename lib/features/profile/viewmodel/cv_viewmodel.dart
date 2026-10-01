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

    // 1. Strict extension validation
    if (!file.name.toLowerCase().endsWith('.pdf')) {
      _errorMessage = 'Invalid file type. Only PDF documents (.pdf) are accepted.';
      notifyListeners();
      return false;
    }

    _isUploading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // 2. Read bytes directly from PlatformFile
      final bytes = await file.readAsBytes();

      // 3. Strict 5 MB limit check matching Supabase bucket
      if (bytes.length > 5 * 1024 * 1024) {
        _errorMessage = 'File too large. CV size must not exceed 5 MB.';
        return false;
      }

      // 4. Magic byte signature check: PDF must start with %PDF (0x25, 0x50, 0x44, 0x46)
      // Disguised .exe files start with MZ (0x4D, 0x5A) and will be blocked here.
      if (!_isGenuinePdf(bytes)) {
        _errorMessage = 'Security error: File is not a valid PDF document.';
        return false;
      }

      _localPdfBytes = bytes;

      // 5. Upload binary to Supabase Storage 'resume' bucket
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
            "Storage bucket 'resumes' not found. Please ensure the bucket named 'resumes' is created in your Supabase dashboard.";
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

  /// Verifies the binary magic bytes (%PDF) to detect disguised executables (.exe) or invalid files.
  bool _isGenuinePdf(Uint8List bytes) {
    if (bytes.length < 4) return false;
    // %PDF in ASCII is 0x25, 0x50, 0x44, 0x46
    return bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
  }
}
