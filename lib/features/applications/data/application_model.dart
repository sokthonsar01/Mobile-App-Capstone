import '../../home/data/internship_model.dart';

/// Application domain entity (Model in MVVM).
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

  static String formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
  }

  static String normalizeStatus(String? backendStatus) {
    switch (backendStatus?.toUpperCase()) {
      case 'PENDING':
        return 'Applied';
      case 'REVIEWED':
        return 'Under Review';
      case 'INTERVIEW':
        return 'Interview';
      case 'ACCEPTED':
        return 'Offer';
      case 'REJECTED':
        return 'Rejected';
      case 'WITHDRAWN':
        return 'Withdrawn';
      default:
        return backendStatus ?? 'Applied';
    }
  }
}
