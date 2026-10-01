import 'dart:convert';
import '../../../config/api_client.dart';
import 'notification_model.dart';

class NotificationRepository {
  /// Fetch all notifications for the authenticated user from NestJS backend.
  static Future<List<AppNotification>> getNotifications() async {
    final response = await ApiClient.get('/notifications');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List list =
          decoded is List ? decoded : (decoded['data'] as List? ?? []);

      final List<AppNotification> fetched = [];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          fetched.add(AppNotification.fromJson(item));
        }
      }
      return fetched;
    }

    if (response.statusCode == 401 || response.statusCode == 404) {
      return [];
    }

    throw Exception('Failed to load notifications: ${response.statusCode}');
  }

  /// Mark a single notification as read.
  static Future<void> markAsRead(String id) async {
    final response = await ApiClient.patch('/notifications/$id/read', {});
    if (response.statusCode != 200 &&
        response.statusCode != 204 &&
        response.statusCode != 404) {
      throw Exception('Failed to mark notification as read: ${response.statusCode}');
    }
  }

  /// Mark all notifications as read.
  static Future<void> markAllAsRead() async {
    final response = await ApiClient.patch('/notifications/read-all', {});
    if (response.statusCode != 200 &&
        response.statusCode != 204 &&
        response.statusCode != 404) {
      throw Exception(
          'Failed to mark all notifications as read: ${response.statusCode}');
    }
  }
}
