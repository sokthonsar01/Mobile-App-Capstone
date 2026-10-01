import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../data/notification_model.dart';
import '../../../shared/theme/app_theme_controller.dart';
import '../../home/presentation/internship_details_screen.dart';
import '../../home/widgets/company_logo_widget.dart';
import '../viewmodel/notifications_viewmodel.dart';

/// The Notifications screen implemented with MVVM architecture.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsViewModel _viewModel = NotificationsViewModel.instance;

  @override
  void initState() {
    super.initState();
    _viewModel.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final notifications = _viewModel.notifications;
        final isLoading = _viewModel.isLoading;

        return ValueListenableBuilder<ThemeMode>(
          valueListenable: AppThemeController.instance.themeModeNotifier,
          builder: (context, currentMode, _) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: isLoading && notifications.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryBlue,
                                strokeWidth: 2.5,
                              ),
                            )
                          : RefreshIndicator(
                              color: AppColors.primaryBlue,
                              onRefresh: () =>
                                  _viewModel.loadNotifications(force: true),
                              child: notifications.isEmpty
                                  ? ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.7,
                                          child: Center(
                                            child: Text(
                                              'No notifications',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: AppColors.hintText,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 4, 16, 16),
                                      physics:
                                          const AlwaysScrollableScrollPhysics(
                                        parent: BouncingScrollPhysics(),
                                      ),
                                      itemCount: notifications.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return _buildRow(
                                            notifications[index], index);
                                      },
                                    ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopBar() {
    final unreadCount = _viewModel.unreadCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new,
                color: AppColors.heading, size: 20),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
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

  Widget _buildRow(AppNotification notification, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unreadBg = isDark
        ? const Color(0xFF1E293B)
        : AppColors.primaryBlue.withValues(alpha: 0.08);

    final readBg = isDark ? const Color(0xFF182032) : AppColors.surface;

    final borderColor = isDark
        ? (notification.isUnread
            ? AppColors.primaryBlue.withValues(alpha: 0.35)
            : const Color(0xFF334155))
        : (notification.isUnread
            ? AppColors.primaryBlue.withValues(alpha: 0.25)
            : AppColors.cardBorder);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isUnread ? unreadBg : readBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: notification.isUnread ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _viewModel.markAsRead(index);

            final targetInternship = notification.resolvedInternship;
            if (targetInternship != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InternshipDetailsScreen(
                    internship: targetInternship,
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CompanyLogoWidget(
                  logoKey: notification.effectiveLogoKey,
                  companyName: notification.companyName,
                  brandColor: notification.effectiveBrandColor,
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: notification.isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: AppColors.heading,
                              ),
                            ),
                          ),
                          if (notification.isUnread) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          height: 1.4,
                          color: AppColors.bodyText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.timeAgo,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.hintText,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon:
                      Icon(Icons.more_vert, color: AppColors.hintText, size: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: AppColors.surface,
                  onSelected: (value) {
                    if (value == 'read') {
                      _viewModel.markAsRead(index);
                    } else if (value == 'delete') {
                      _viewModel.removeAt(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Notification removed',
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'read',
                      child: Text(
                        'Mark as read',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.heading,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _markAllAsRead() {
    _viewModel.markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'All notifications marked as read',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
