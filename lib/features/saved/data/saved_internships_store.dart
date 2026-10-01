import 'package:flutter/foundation.dart';
import '../../home/data/internship_model.dart';
import '../viewmodel/saved_internships_viewmodel.dart';

/// Adapter store bridging to SavedInternshipsViewModel (MVVM).
/// Ensures backward compatibility with existing listeners.
class SavedInternshipsStore {
  SavedInternshipsStore._() {
    SavedInternshipsViewModel.instance.addListener(() {
      savedIdsNotifier.value = SavedInternshipsViewModel.instance.savedIds;
      isLoadingNotifier.value = SavedInternshipsViewModel.instance.isLoading;
    });
  }

  static final SavedInternshipsStore instance = SavedInternshipsStore._();

  final ValueNotifier<Set<String>> savedIdsNotifier =
      ValueNotifier<Set<String>>(<String>{});

  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  Set<String> get savedIds => SavedInternshipsViewModel.instance.savedIds;

  bool isSaved(String id) => SavedInternshipsViewModel.instance.isSaved(id);

  Future<void> fetchSavedInternships({bool force = false}) =>
      SavedInternshipsViewModel.instance.loadSavedInternships(force: force);

  Future<void> toggleSave(String id, {InternshipOpportunity? item}) async {
    if (item != null) {
      await SavedInternshipsViewModel.instance.toggleSave(item);
    } else if (isSaved(id)) {
      await SavedInternshipsViewModel.instance.remove(id);
    }
  }

  Future<void> save(String id, {InternshipOpportunity? item}) async {
    if (item != null) {
      await SavedInternshipsViewModel.instance.save(item);
    }
  }

  Future<void> remove(String id) =>
      SavedInternshipsViewModel.instance.remove(id);

  Future<void> clearAll() => SavedInternshipsViewModel.instance.clearAll();

  List<InternshipOpportunity> getSavedOpportunities() =>
      SavedInternshipsViewModel.instance.savedInternships;
}
