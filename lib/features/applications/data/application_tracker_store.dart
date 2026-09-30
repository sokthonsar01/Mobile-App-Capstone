import 'package:flutter/foundation.dart';
import '../../home/data/internship_model.dart';
import 'application_model.dart';
import '../viewmodel/application_tracker_viewmodel.dart';

export 'application_model.dart';

/// Adapter store bridging to ApplicationTrackerViewModel (MVVM)
class ApplicationTrackerStore extends ValueNotifier<List<TrackedApplication>> {
  static final ApplicationTrackerStore instance =
      ApplicationTrackerStore._internal();

  ApplicationTrackerStore._internal() : super([]) {
    ApplicationTrackerViewModel.instance.addListener(() {
      value = ApplicationTrackerViewModel.instance.applications;
    });
  }

  static String formatDateTime(DateTime dt) =>
      TrackedApplication.formatDateTime(dt);

  static String normalizeStatus(String? status) =>
      TrackedApplication.normalizeStatus(status);

  void resetToDefaults() =>
      ApplicationTrackerViewModel.instance.resetToDefaults();

  void syncFromBackend(List<dynamic> raw) =>
      ApplicationTrackerViewModel.instance.syncFromBackend(raw);

  bool applyForInternship(InternshipOpportunity item) =>
      ApplicationTrackerViewModel.instance.applyForInternship(item);

  void updateStatus(String appId, String newStatus) =>
      ApplicationTrackerViewModel.instance.updateStatus(appId, newStatus);

  bool removeFromTracker(String appId) =>
      ApplicationTrackerViewModel.instance.removeFromTracker(appId);
}
