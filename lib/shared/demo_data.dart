/// Fake data so the screens have something to show before the backend exists.
///
/// Delete this whole file when the real API is connected.
/// Nothing here talks to a server. It is just lists we typed by hand.

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

  const ChatPreview({
    required this.name,
    required this.lastMessage,
    required this.timeAgo,
    this.unreadCount = 0,
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

  const AppNotification({
    required this.companyName,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isUnread = false,
  });
}

// ---------------------------------------------------------------------------
// The fake lists
// ---------------------------------------------------------------------------

const List<ChatPreview> demoChats = [
  ChatPreview(
    name: 'Taylor Swift',
    lastMessage: 'Oh yes, please send your CV/Resume here',
    timeAgo: '5m ago',
    unreadCount: 2,
  ),
  ChatPreview(
    name: 'Michael C. Hall',
    lastMessage: 'I recently applied for the UI/UX Designer internship',
    timeAgo: '5m ago',
  ),
  ChatPreview(
    name: 'Laufey',
    lastMessage: 'I recently applied for the Data Analyst internship',
    timeAgo: '5m ago',
  ),
  ChatPreview(
    name: 'Sabrina Carpenter',
    lastMessage: 'I recently applied for the Marketing internship',
    timeAgo: '5m ago',
  ),
  ChatPreview(
    name: 'Jenna Ortega',
    lastMessage: 'I recently applied for the Finance internship',
    timeAgo: '5m ago',
  ),
  ChatPreview(
    name: 'Andrew Garfield',
    lastMessage: 'I recently applied for the AI Specialist internship',
    timeAgo: '5m ago',
  ),
  ChatPreview(
    name: 'Laufey',
    lastMessage: 'I recently applied for the Data Science internship',
    timeAgo: '5m ago',
  ),
];

const List<ChatMessage> demoConversation = [
  ChatMessage(
    text: "Hello M'am, Good Morning",
    time: '09:30 am',
    isMine: true,
  ),
  ChatMessage(
    text: 'Morning, Can I help you ?',
    time: '09:31 am',
    isMine: false,
  ),
  ChatMessage(
    text: 'I recently applied for the UI/UX Designer internship through '
        'your internship portal and wanted to ask if the application '
        'review has started.',
    time: '09:33 am',
    isMine: true,
  ),
  ChatMessage(
    text: 'Yes, our team has started reviewing the applications and will '
        'contact shortlisted candidates soon.',
    time: '09:35 am',
    isMine: false,
  ),
  ChatMessage(
    text: 'Thank you for the update. I look forward to hearing from '
        'your team.',
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
  ),
  AppNotification(
    companyName: 'Smart Axiata',
    title: 'Application Submitted',
    body: 'Your application for the UX/UI Intern position at Smart Axiata '
        'has been successfully submitted.',
    timeAgo: '2 hours ago',
  ),
  AppNotification(
    companyName: 'ABA Bank',
    title: 'Shortlisted',
    body: 'You have been shortlisted for the Finance Intern position at '
        'ABA Bank. Check your application details for the next steps.',
    timeAgo: '3 hours ago',
  ),
  AppNotification(
    companyName: 'Cellcard',
    title: 'Interview Invitation',
    body: 'Cellcard has invited you to interview for the AI Specialist '
        'Intern position. View your application details for more '
        'information.',
    timeAgo: '5 hours ago',
  ),
  AppNotification(
    companyName: 'Chip Mong',
    title: 'Application Under Review',
    body: 'Your application for the Marketing Intern position at Chip Mong '
        'is currently being reviewed by the employer.',
    timeAgo: '1 day ago',
  ),
  AppNotification(
    companyName: 'Hanuman Estate',
    title: 'Application Decision',
    body: 'A decision has been made on your application. Open the '
        'application to see the result.',
    timeAgo: '2 days ago',
  ),
];
