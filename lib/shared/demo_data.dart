/// Fake data so the screens have something to show before the backend exists.
///
/// Delete this whole file when the real API is connected.
/// Nothing here talks to a server. It is just lists we typed by hand.
library;

import 'package:flutter/material.dart';
import '../features/home/data/internship_model.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

/// One row in the Messages list.
class ChatPreview {
  final String name;
  final String lastMessage;
  final String timeAgo;

  /// How many messages the user has not read. 0 means no blue badge.
  final int unreadCount;

  /// Optional logo or avatar asset path.
  final String? avatarAsset;

  const ChatPreview({
    required this.name,
    required this.lastMessage,
    required this.timeAgo,
    this.unreadCount = 0,
    this.avatarAsset,
  });
}

/// One bubble inside a chat.
class ChatMessage {
  final String text;
  final String time;

  /// true  = the user wrote it  -> blue bubble on the right
  /// false = the other person   -> light bubble on the left
  final bool isMine;

  const ChatMessage({
    required this.text,
    required this.time,
    required this.isMine,
  });
}

/// One saved internship card.
class SavedInternship {
  final String title;
  final String company;
  final String location;

  /// The small gray tags, for example ["Marketing", "Full time"].
  final List<String> tags;

  final String postedAgo;
  final String payType;

  const SavedInternship({
    required this.title,
    required this.company,
    required this.location,
    required this.tags,
    required this.postedAgo,
    required this.payType,
  });
}

/// One notification row.
class AppNotification {
  final String companyName;
  final String title;
  final String body;
  final String timeAgo;

  /// true = show the pale blue background.
  final bool isUnread;

  /// Optional internship ID linking this notification to an internship opportunity.
  final String? internshipId;

  /// Optional explicit logo key. If null, automatically resolved from the company posting.
  final String? logoKey;

  /// Optional explicit brand accent color. If null, automatically resolved from the company posting.
  final Color? brandColor;

  const AppNotification({
    required this.companyName,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isUnread = false,
    this.internshipId,
    this.logoKey,
    this.brandColor,
  });

  /// Factory constructor to automatically create a notification from an internship posting.
  factory AppNotification.fromInternship({
    required InternshipOpportunity internship,
    required String title,
    required String body,
    required String timeAgo,
    bool isUnread = false,
  }) {
    return AppNotification(
      companyName: internship.company,
      title: title,
      body: body,
      timeAgo: timeAgo,
      isUnread: isUnread,
      internshipId: internship.id,
      logoKey: internship.logoKey,
      brandColor: internship.brandColor,
    );
  }

  /// Resolves the matching internship opportunity automatically from the company that posted it.
  InternshipOpportunity? get resolvedInternship {
    if (internshipId != null && internshipId!.isNotEmpty) {
      try {
        return demoInternships.firstWhere((i) => i.id == internshipId);
      } catch (_) {}
    }
    return findInternshipByCompany(companyName);
  }

  /// Automatically retrieves the correct company logo key from the internship poster.
  String get effectiveLogoKey {
    if (logoKey != null && logoKey!.isNotEmpty) return logoKey!;
    return resolvedInternship?.logoKey ?? '';
  }

  /// Automatically retrieves the correct company brand color from the internship poster.
  Color get effectiveBrandColor {
    if (brandColor != null) return brandColor!;
    return resolvedInternship?.brandColor ?? const Color(0xFF1E3A8A);
  }

  AppNotification copyWith({
    String? companyName,
    String? title,
    String? body,
    String? timeAgo,
    bool? isUnread,
    String? internshipId,
    String? logoKey,
    Color? brandColor,
  }) {
    return AppNotification(
      companyName: companyName ?? this.companyName,
      title: title ?? this.title,
      body: body ?? this.body,
      timeAgo: timeAgo ?? this.timeAgo,
      isUnread: isUnread ?? this.isUnread,
      internshipId: internshipId ?? this.internshipId,
      logoKey: logoKey ?? this.logoKey,
      brandColor: brandColor ?? this.brandColor,
    );
  }
}

// ---------------------------------------------------------------------------
// The fake lists
// ---------------------------------------------------------------------------

const List<ChatPreview> demoChats = [
  ChatPreview(
    name: 'Chip Mong Careers',
    lastMessage: 'Oh yes, please send your CV/Resume here',
    timeAgo: '5m ago',
    unreadCount: 2,
    avatarAsset: 'assets/images/logos/Chigmong logo.png',
  ),
  ChatPreview(
    name: 'Smart Axiata HR',
    lastMessage: 'We reviewed your application for the Flutter Developer internship',
    timeAgo: '15m ago',
    unreadCount: 1,
    avatarAsset: 'assets/images/logos/smart logo.png',
  ),
  ChatPreview(
    name: 'Canadia Bank Recruitment',
    lastMessage: 'Your interview is scheduled for this Thursday at 2:00 PM',
    timeAgo: '1h ago',
    avatarAsset: 'assets/images/logos/Canada bank logo.png',
  ),
  ChatPreview(
    name: 'Cellcard Talent Team',
    lastMessage: 'Thank you for applying for the AI Specialist internship',
    timeAgo: '3h ago',
    avatarAsset: 'assets/images/logos/Cellcard logo.png',
  ),
  ChatPreview(
    name: 'ABA Bank Careers',
    lastMessage: 'We received your application and will contact shortlisted candidates soon',
    timeAgo: '1d ago',
    avatarAsset: 'assets/images/logos/ABA Logo.png',
  ),
  ChatPreview(
    name: 'Hanuman Beverages',
    lastMessage: 'Congratulations! You have been shortlisted for the Data Analyst role',
    timeAgo: '2d ago',
    avatarAsset: 'assets/images/logos/Hanuman beer logo.png',
  ),
  ChatPreview(
    name: 'MoEYS Digital Tech',
    lastMessage: 'Please check your email for the technical project guidelines',
    timeAgo: '3d ago',
    avatarAsset: 'assets/images/logos/Moeys Logo.png',
  ),
  ChatPreview(
    name: 'Sokha Chan (Chip Mong)',
    lastMessage: 'Looking forward to welcoming you at our Phnom Penh head office',
    timeAgo: '4d ago',
  ),
  ChatPreview(
    name: 'Bopha Heng (Canadia Bank)',
    lastMessage: 'Your portfolio has been forwarded to the software team lead',
    timeAgo: '5d ago',
  ),
];

const List<ChatMessage> demoConversation = [
  ChatMessage(
    text: "Hello! Good morning from CADT.",
    time: '09:30 am',
    isMine: true,
  ),
  ChatMessage(
    text: 'Hello Chhouen Ratanaksombo! How can our recruitment team help you today?',
    time: '09:31 am',
    isMine: false,
  ),
  ChatMessage(
    text: 'I recently applied for the Mobile App Developer internship through '
        'the Interna portal and wanted to confirm if my submission was received.',
    time: '09:33 am',
    isMine: true,
  ),
  ChatMessage(
    text: 'Yes! We have received your application and Chhouen_Ratanaksombo_CV.pdf. '
        'Our tech leads are impressed with your Flutter projects and will contact you for the interview round soon.',
    time: '09:35 am',
    isMine: false,
  ),
  ChatMessage(
    text: 'Thank you so much! I look forward to hearing from your team.',
    time: '09:40 am',
    isMine: true,
  ),
];

const List<SavedInternship> demoSavedInternships = [
  SavedInternship(
    title: 'Marketing Intern',
    company: 'Chip Mong',
    location: 'Phnom Penh, Cambodia',
    tags: ['Marketing', 'Full time', 'Entry Level'],
    postedAgo: '25 minute ago',
    payType: 'Paid Internship',
  ),
  SavedInternship(
    title: 'AI Specialist Intern',
    company: 'Cellcard',
    location: 'Phnom Penh, Cambodia',
    tags: ['Technology', 'Full time', 'Entry Level'],
    postedAgo: '28 minute ago',
    payType: 'Paid Internship',
  ),
  SavedInternship(
    title: 'Data Analyst Intern',
    company: 'Hanuman Beverages',
    location: 'Phnom Penh, Cambodia',
    tags: ['Data', 'Full time', 'Analytics'],
    postedAgo: '35 minute ago',
    payType: 'Paid Internship',
  ),
];

const List<AppNotification> demoNotifications = [
  AppNotification(
    companyName: 'Hanuman Estate',
    title: 'Application Under Review',
    body: 'Your application for the Data Science Intern position at '
        'Hanuman Estate is currently being reviewed by the employer.',
    timeAgo: '25 minutes ago',
    isUnread: true,
    internshipId: 'hanuman-06',
    logoKey: 'hanuman',
    brandColor: Color(0xFF1565C0),
  ),
  AppNotification(
    companyName: 'Smart Axiata',
    title: 'Application Submitted',
    body: 'Your application for the UX/UI Intern position at Smart Axiata '
        'has been successfully submitted.',
    timeAgo: '2 hours ago',
    internshipId: 'smart-05',
    logoKey: 'smart',
    brandColor: Color(0xFF2E7D32),
  ),
  AppNotification(
    companyName: 'ABA Bank',
    title: 'Shortlisted',
    body: 'You have been shortlisted for the Finance Intern position at '
        'ABA Bank. Check your application details for the next steps.',
    timeAgo: '3 hours ago',
    internshipId: 'aba-04',
    logoKey: 'aba',
    brandColor: Color(0xFF003D6B),
  ),
  AppNotification(
    companyName: 'Cellcard',
    title: 'Interview Invitation',
    body: 'Cellcard has invited you to interview for the AI Specialist '
        'Intern position. View your application details for more '
        'information.',
    timeAgo: '5 hours ago',
    internshipId: 'cellcard-03',
    logoKey: 'cellcard',
    brandColor: Color(0xFFFF9800),
  ),
  AppNotification(
    companyName: 'Chip Mong',
    title: 'Application Under Review',
    body: 'Your application for the Marketing Intern position at Chip Mong '
        'is currently being reviewed by the employer.',
    timeAgo: '1 day ago',
    internshipId: 'cm-01',
    logoKey: 'chip_mong',
    brandColor: Color(0xFFE91E63),
  ),
  AppNotification(
    companyName: 'Hanuman Estate',
    title: 'Application Decision',
    body: 'A decision has been made on your application. Open the '
        'application to see the result.',
    timeAgo: '2 days ago',
    internshipId: 'hanuman-06',
    logoKey: 'hanuman',
    brandColor: Color(0xFF1565C0),
  ),
];
