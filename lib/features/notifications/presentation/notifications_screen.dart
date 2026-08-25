import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/demo_data.dart';
import '../../../shared/widgets/shared_widgets.dart';

/// The Notifications screen.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  /// A copy we can change, so "Read all" can turn off the blue backgrounds.
  late List<AppNotification> _notifications =
      List<AppNotification>.from(demoNotifications);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: _notifications.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildRow(_notifications[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.black, size: 20),
          ),
          Expanded(
            child: Text(
              'Notifications',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.heading,
              ),
            ),
          ),
          GestureDetector(
            onTap: _markAllAsRead,
            child: Text(
              'Read all',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(AppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // Unread rows get the pale blue background.
        color: notification.isUnread ? AppColors.unreadBlue : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: notification.isUnread ? null : softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InitialsAvatar(
            name: notification.companyName,
            size: 40,
            isSquare: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  notification.body,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    height: 1.45,
                    color: AppColors.bodyText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.timeAgo,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.hintText,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.black54, size: 20),
        ],
      ),
    );
  }

  /// Builds a new list where every item has isUnread = false.
  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => AppNotification(
                companyName: n.companyName,
                title: n.title,
                body: n.body,
                timeAgo: n.timeAgo,
                isUnread: false,
              ))
          .toList();
    });
  }
}
