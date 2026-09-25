import 'package:flutter/foundation.dart';
import 'internship_model.dart';

/// Tracked application data model.
class TrackedApplication {
  final String id;
  final InternshipOpportunity internship;
  final String appliedDate;
  final String deadline;
  String lastUpdated;
  String status; // 'Applied', 'Under Review', 'Interview', 'Offer', 'Rejected', 'Withdrawn'
  final String? interviewInfo;

  TrackedApplication({
    required this.id,
    required this.internship,
    required this.appliedDate,
    required this.deadline,
    required this.lastUpdated,
    required this.status,
    this.interviewInfo,
  });
}

/// Global reactive singleton store managing application tracking state.
class ApplicationTrackerStore extends ValueNotifier<List<TrackedApplication>> {
  static final ApplicationTrackerStore instance =
      ApplicationTrackerStore._internal();

  ApplicationTrackerStore._internal() : super([]) {
    _initDefaultApplications();
  }

  void _initDefaultApplications() {
    value = [
      TrackedApplication(
        id: 'app-01',
        internship: demoInternships.firstWhere(
          (e) => e.logoKey == 'chip_mong',
          orElse: () => demoInternships[0],
        ),
        appliedDate: 'Jan 15, 2026',
        lastUpdated: 'Feb 02, 2026',
        deadline: 'Feb 14, 2026',
        status: 'Under Review',
      ),
      TrackedApplication(
        id: 'app-02',
        internship: demoInternships.firstWhere(
          (e) => e.logoKey == 'canadia',
          orElse: () => demoInternships[1],
        ),
        appliedDate: 'Jan 20, 2026',
        lastUpdated: 'Feb 08, 2026',
        deadline: 'Feb 23, 2026',
        status: 'Interview',
        interviewInfo:
            'Scheduled for Feb 28, 2026 at 10:00 AM (Google Meet Video Call)',
      ),
      TrackedApplication(
        id: 'app-03',
        internship: demoInternships.firstWhere(
          (e) => e.logoKey == 'cellcard',
          orElse: () => demoInternships[2],
        ),
        appliedDate: 'Jan 10, 2026',
        lastUpdated: 'Feb 12, 2026',
        deadline: 'Feb 14, 2026',
        status: 'Offer',
        interviewInfo: 'Offer Extended • Response Deadline: March 01, 2026',
      ),
      TrackedApplication(
        id: 'app-04',
        internship: demoInternships.firstWhere(
          (e) => e.logoKey == 'aba',
          orElse: () => demoInternships[3],
        ),
        appliedDate: 'Feb 01, 2026',
        lastUpdated: 'Feb 01, 2026',
        deadline: 'Feb 14, 2026',
        status: 'Applied',
      ),
      TrackedApplication(
        id: 'app-05',
        internship: demoInternships.firstWhere(
          (e) => e.logoKey == 'smart',
          orElse: () => demoInternships[4],
        ),
        appliedDate: 'Jan 05, 2026',
        lastUpdated: 'Jan 25, 2026',
        deadline: 'Feb 14, 2026',
        status: 'Rejected',
      ),
    ];
  }

  /// Reset store back to initial default applications (useful for testing)
  void resetToDefaults() {
    _initDefaultApplications();
  }

  /// Automatically add or update an application when a user applies. Avoids duplicate cards.
  bool applyForInternship(InternshipOpportunity item) {
    final existingIndex = value.indexWhere((app) => app.internship.id == item.id);
    const todayStr = 'Feb 14, 2026';

    if (existingIndex != -1) {
      final updatedList = List<TrackedApplication>.from(value);
      updatedList[existingIndex].status = 'Applied';
      updatedList[existingIndex].lastUpdated = todayStr;
      value = updatedList;
      return false; // updated existing
    } else {
      final newApp = TrackedApplication(
        id: 'app-${DateTime.now().millisecondsSinceEpoch}',
        internship: item,
        appliedDate: todayStr,
        lastUpdated: todayStr,
        deadline: item.deadline,
        status: 'Applied',
      );
      value = [newApp, ...value];
      return true; // new application added
    }
  }

  /// Update application status (e.g. to Withdrawn)
  void updateStatus(String appId, String newStatus) {
    final updatedList = List<TrackedApplication>.from(value);
    final index = updatedList.indexWhere((app) => app.id == appId);
    if (index != -1) {
      updatedList[index].status = newStatus;
      updatedList[index].lastUpdated = 'Feb 14, 2026';
      value = updatedList;
    }
  }

  /// Remove a withdrawn or rejected application from history (cannot delete active apps)
  bool removeFromTracker(String appId) {
    final index = value.indexWhere((app) => app.id == appId);
    if (index != -1) {
      final app = value[index];
      if (app.status == 'Withdrawn' || app.status == 'Rejected') {
        value = value.where((a) => a.id != appId).toList();
        return true;
      }
    }
    return false;
  }
}
