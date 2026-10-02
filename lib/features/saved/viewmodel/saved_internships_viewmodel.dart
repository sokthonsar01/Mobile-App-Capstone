import 'package:flutter/foundation.dart';
import '../../home/data/internship_model.dart';
import '../data/saved_internship_repository.dart';

class SavedInternshipsViewModel extends ChangeNotifier {
  static final SavedInternshipsViewModel instance =
      SavedInternshipsViewModel._internal();

  SavedInternshipsViewModel._internal();

  // Observable state
  List<InternshipOpportunity> _savedInternships = [];
  Set<String> _savedIds = <String>{};
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _errorMessage;

  // Getters
  List<InternshipOpportunity> get savedInternships =>
      List.unmodifiable(_savedInternships);
  Set<String> get savedIds => _savedIds;
  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;
  String? get errorMessage => _errorMessage;

  bool isSaved(String id) => _savedIds.contains(id);

  /// Reset state (useful for tests or user switch)
  void resetToDefaults() {
    _savedInternships = [];
    _savedIds = <String>{};
    _isLoading = false;
    _hasLoadedOnce = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Load bookmarked internships from the backend
  Future<void> loadSavedInternships({bool force = false}) async {
    final isBackground = _hasLoadedOnce && !force;
    if (!isBackground) {
      if (_isLoading) return;
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final remoteList = await SavedInternshipRepository.getSavedInternships();
      _savedInternships = remoteList;
      _savedIds = remoteList.map((item) => item.id).toSet();
      _hasLoadedOnce = true;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle bookmark for an internship
  Future<void> toggleSave(InternshipOpportunity item) async {
    if (isSaved(item.id)) {
      await remove(item.id);
    } else {
      await save(item);
    }
  }

  /// Bookmark an internship (optimistic update + backend sync)
  Future<void> save(InternshipOpportunity item) async {
    if (!_savedIds.contains(item.id)) {
      _savedIds = Set<String>.from(_savedIds)..add(item.id);
      if (!_savedInternships.any((o) => o.id == item.id)) {
        _savedInternships.insert(0, item);
      }
      notifyListeners();
    }

    try {
      await SavedInternshipRepository.saveInternship(item.id);
    } catch (e) {
      // Offline fallback: keep local state
    }
  }

  /// Remove bookmark (optimistic update + backend sync)
  Future<void> remove(String id) async {
    if (_savedIds.contains(id)) {
      _savedIds = Set<String>.from(_savedIds)..remove(id);
      _savedInternships.removeWhere((item) => item.id == id);
      notifyListeners();
    }

    try {
      await SavedInternshipRepository.removeInternship(id);
    } catch (e) {
      // Offline fallback
    }
  }

  /// Clear all bookmarks
  Future<void> clearAll() async {
    final idsToClear = List<String>.from(_savedIds);
    _savedIds = <String>{};
    _savedInternships.clear();
    notifyListeners();

    for (final id in idsToClear) {
      try {
        await SavedInternshipRepository.removeInternship(id);
      } catch (_) {}
    }
  }
}
