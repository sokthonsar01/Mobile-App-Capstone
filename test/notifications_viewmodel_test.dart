import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/notifications/data/notification_model.dart';
import 'package:interna/features/notifications/viewmodel/notifications_viewmodel.dart';

void main() {
  test('NotificationsViewModel starts empty (zero dummy data) and manages unread count', () async {
    final viewModel = NotificationsViewModel.instance;
    viewModel.resetToDefaults();

    // 1. Initial state has zero dummy data
    expect(viewModel.notifications, isEmpty);
    expect(viewModel.unreadCount, equals(0));

    // 2. Populate notifications
    final sampleItems = [
      const AppNotification(
        id: 'notif-01',
        companyName: 'Chip Mong',
        title: 'Interview Scheduled',
        body: 'Interview at 10:00 AM',
        timeAgo: '1h ago',
        isUnread: true,
      ),
      const AppNotification(
        id: 'notif-02',
        companyName: 'Smart Axiata',
        title: 'Offer Extended',
        body: 'Congratulations on your offer!',
        timeAgo: '2h ago',
        isUnread: true,
      ),
    ];

    int notifyCount = 0;
    viewModel.addListener(() => notifyCount++);

    viewModel.setNotifications(sampleItems);
    expect(viewModel.notifications.length, equals(2));
    expect(viewModel.unreadCount, equals(2));

    // 3. Mark single notification as read
    await viewModel.markAsRead(0);
    expect(viewModel.notifications[0].isUnread, isFalse);
    expect(viewModel.unreadCount, equals(1));
    expect(notifyCount, greaterThan(0));

    // 4. Mark all as read
    await viewModel.markAllAsRead();
    expect(viewModel.unreadCount, equals(0));
    expect(viewModel.notifications.every((n) => !n.isUnread), isTrue);

    // 5. Remove notification
    final countBefore = viewModel.notifications.length;
    viewModel.removeAt(0);
    expect(viewModel.notifications.length, equals(countBefore - 1));
  });
}
