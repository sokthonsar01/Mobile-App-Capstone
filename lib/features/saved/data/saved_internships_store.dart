import 'package:flutter/foundation.dart';
import '../../home/data/internship_model.dart';

/// Centralized store managing saved/bookmarked internship opportunities across the app.
/// Ensures real-time state synchronization between HomeScreen, InternshipDetailsScreen,
/// InternshipDetailsSheet, and SavedInternshipsScreen.
class SavedInternshipsStore {
  SavedInternshipsStore._();
  static final SavedInternshipsStore instance = SavedInternshipsStore._();

  /// Reactive set of bookmarked opportunity IDs.
  final ValueNotifier<Set<String>> savedIdsNotifier =
      ValueNotifier<Set<String>>({'cm-01', 'cellcard-03'});

  Set<String> get savedIds => savedIdsNotifier.value;

  bool isSaved(String id) => savedIdsNotifier.value.contains(id);

  void toggleSave(String id) {
    final updated = Set<String>.from(savedIdsNotifier.value);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    savedIdsNotifier.value = updated;
  }

  void save(String id) {
    if (!savedIdsNotifier.value.contains(id)) {
      final updated = Set<String>.from(savedIdsNotifier.value)..add(id);
      savedIdsNotifier.value = updated;
    }
  }

  void remove(String id) {
    if (savedIdsNotifier.value.contains(id)) {
      final updated = Set<String>.from(savedIdsNotifier.value)..remove(id);
      savedIdsNotifier.value = updated;
    }
  }

  void clearAll() {
    savedIdsNotifier.value = <String>{};
  }

  /// Returns the list of full InternshipOpportunity models currently saved.
  List<InternshipOpportunity> getSavedOpportunities() {
    final ids = savedIdsNotifier.value;
    return demoInternships.where((item) => ids.contains(item.id)).toList();
  }
}
