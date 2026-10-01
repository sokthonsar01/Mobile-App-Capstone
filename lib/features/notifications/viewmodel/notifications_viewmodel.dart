import 'package:flutter/foundation.dart';
import '../data/notification_model.dart';
import '../data/notification_repository.dart';

class NotificationsViewModel extends ChangeNotifier {
  static final NotificationsViewModel instance =
      NotificationsViewModel._internal();

  NotificationsViewModel._internal();

  // Observable state
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((n) => n.isUnread).length;

  /// Clear state
  void resetToDefaults() {
    _notifications = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Manually populate for tests
  void setNotifications(List<AppNotification> items) {
    _notifications = List.from(items);
    notifyListeners();
  }

  /// Load live notifications from backend NestJS API (zero dummy data)
  Future<void> loadNotifications({bool force = false}) async {
    if (_isLoading && !force) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final remoteList = await NotificationRepository.getNotifications();
      _notifications = remoteList;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark single notification as read
  Future<void> markAsRead(int index) async {
    if (index < 0 || index >= _notifications.length) return;
    final item = _notifications[index];
    if (!item.isUnread) return;

    _notifications[index] = item.copyWith(isUnread: false);
    notifyListeners();

    if (item.id.isNotEmpty) {
      try {
        await NotificationRepository.markAsRead(item.id);
      } catch (_) {
        // Offline fallback
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    _notifications = _notifications
        .map((notification) => notification.copyWith(isUnread: false))
        .toList();
    notifyListeners();

    try {
      await NotificationRepository.markAllAsRead();
    } catch (_) {
      // Offline fallback
    }
  }

  /// Remove notification row
  void removeAt(int index) {
    if (index < 0 || index >= _notifications.length) return;
    _notifications.removeAt(index);
    notifyListeners();
  }
}
