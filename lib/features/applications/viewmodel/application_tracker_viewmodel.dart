import 'package:flutter/foundation.dart';
import '../../home/data/internship_model.dart';
import '../data/application_model.dart';
import '../data/application_repository.dart';

class ApplicationTrackerViewModel extends ChangeNotifier {
  static final ApplicationTrackerViewModel instance =
      ApplicationTrackerViewModel._internal();

  ApplicationTrackerViewModel._internal();

  // Observable state
  List<TrackedApplication> _applications = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'All';

  final List<String> filters = const [
    'All',
    'Applied',
    'Under Review',
    'Interview',
    'Offer',
    'Rejected',
    'Withdrawn',
  ];

  // Getters
  List<TrackedApplication> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;

  List<TrackedApplication> get filteredApplications {
    if (_selectedFilter == 'All') {
      return _applications;
    }
    return _applications
        .where((app) => app.status == _selectedFilter)
        .toList();
  }

  int countByStatus(String status) {
    return _applications.where((app) => app.status == status).length;
  }

  // State actions
  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  /// Reset store for test fixtures
  void resetToDefaults() {
    _applications = [];
    _selectedFilter = 'All';
    _errorMessage = null;
    notifyListeners();
  }

  /// Load live applications from backend
  Future<void> loadApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final remoteApps = await ApplicationRepository.getMyApplications();
      _applications = remoteApps;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Apply for an internship (local state update + reactive sync)
  bool applyForInternship(InternshipOpportunity item) {
    final existingIndex =
        _applications.indexWhere((app) => app.internship.id == item.id);
    final todayStr = TrackedApplication.formatDateTime(DateTime.now());

    if (existingIndex != -1) {
      _applications[existingIndex].status = 'Applied';
      _applications[existingIndex].lastUpdated = todayStr;
      notifyListeners();
      return false;
    } else {
      final newApp = TrackedApplication(
        id: 'app-${DateTime.now().millisecondsSinceEpoch}',
        internship: item,
        appliedDate: todayStr,
        lastUpdated: todayStr,
        deadline: item.deadline,
        status: 'Applied',
      );
      _applications = [newApp, ..._applications];
      notifyListeners();
      return true;
    }
  }

  /// Apply for an internship via live backend API
  Future<TrackedApplication> applyViaApi({
    required String internshipId,
    required String resumeId,
    String? coverLetter,
    String? portfolioLink,
  }) async {
    final newApp = await ApplicationRepository.apply(
      internshipId: internshipId,
      resumeId: resumeId,
      coverLetter: coverLetter,
      portfolioLink: portfolioLink,
    );

    final existingIndex =
        _applications.indexWhere((a) => a.internship.id == internshipId);
    if (existingIndex != -1) {
      _applications[existingIndex] = newApp;
    } else {
      _applications = [newApp, ..._applications];
    }

    notifyListeners();
    return newApp;
  }

  /// Update application status (e.g. locally or after user action)
  void updateStatus(String appId, String newStatus) {
    final index = _applications.indexWhere((app) => app.id == appId);
    if (index != -1) {
      _applications[index].status = newStatus;
      _applications[index].lastUpdated =
          TrackedApplication.formatDateTime(DateTime.now());
      notifyListeners();
    }
  }

  /// Withdraw an active application (calls backend + updates UI state)
  Future<void> withdraw(String appId) async {
    updateStatus(appId, 'Withdrawn');
    try {
      await ApplicationRepository.withdraw(appId);
    } catch (_) {
      // Status remains Withdrawn locally even if network fails
    }
  }

  /// Remove a withdrawn or rejected application from tracker history
  bool removeFromTracker(String appId) {
    final index = _applications.indexWhere((app) => app.id == appId);
    if (index != -1) {
      final app = _applications[index];
      if (app.status == 'Withdrawn' || app.status == 'Rejected') {
        _applications = _applications.where((a) => a.id != appId).toList();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Sync applications parsed from student profile
  void syncFromBackend(List<dynamic> rawApps) {
    final List<TrackedApplication> mapped = [];
    for (final raw in rawApps) {
      if (raw is! Map<String, dynamic>) continue;
      final rawInternship = raw['internship'] as Map<String, dynamic>?;
      if (rawInternship == null) continue;

      final internship = InternshipOpportunity.fromJson(rawInternship);
      final appliedAt = raw['appliedAt'] != null
          ? DateTime.tryParse(raw['appliedAt'].toString())
          : null;
      final appliedDateStr = appliedAt != null
          ? TrackedApplication.formatDateTime(appliedAt)
          : TrackedApplication.formatDateTime(DateTime.now());

      mapped.add(
        TrackedApplication(
          id: raw['id']?.toString() ?? 'app-${mapped.length}',
          internship: internship,
          appliedDate: appliedDateStr,
          deadline: internship.deadline,
          lastUpdated: appliedDateStr,
          status:
              TrackedApplication.normalizeStatus(raw['status']?.toString()),
        ),
      );
    }
    _applications = mapped;
    notifyListeners();
  }
}
