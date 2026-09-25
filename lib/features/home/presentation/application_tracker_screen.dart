import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../data/application_tracker_store.dart';
import '../data/internship_model.dart';
import '../widgets/company_logo_widget.dart';
import '../widgets/internship_details_sheet.dart';
import 'home_screen.dart';

/// The main Application Tracker Page for students to track every internship applied for.
class ApplicationTrackerScreen extends StatefulWidget {
  const ApplicationTrackerScreen({super.key});

  @override
  State<ApplicationTrackerScreen> createState() =>
      _ApplicationTrackerScreenState();
}

class _ApplicationTrackerScreenState extends State<ApplicationTrackerScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Applied',
    'Under Review',
    'Interview',
    'Offer',
    'Rejected',
    'Withdrawn',
  ];

  // Count helper functions for summary cards
  int _countByStatus(List<TrackedApplication> apps, String status) {
    return apps.where((app) => app.status == status).length;
  }

  List<TrackedApplication> _filterApplications(List<TrackedApplication> apps) {
    if (_selectedFilter == 'All') {
      return apps;
    }
    return apps.where((app) => app.status == _selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Applied':
        return const Color(0xFF2563EB); // Blue
      case 'Under Review':
        return const Color(0xFF7C3AED); // Purple
      case 'Interview':
        return const Color(0xFFEA580C); // Orange
      case 'Offer':
        return const Color(0xFF16A34A); // Green
      case 'Rejected':
        return const Color(0xFFDC2626); // Red
      case 'Withdrawn':
        return const Color(0xFF64748B); // Slate Grey
      default:
        return AppColors.primaryBlue;
    }
  }

  /// Show confirmation popup before withdrawing application or declining offer
  void _confirmWithdrawOrDecline(TrackedApplication app) {
    final isOffer = app.status == 'Offer';
    final actionTitle = isOffer ? 'Decline Offer' : 'Withdraw Application';
    final actionMessage = isOffer
        ? 'Are you sure you want to decline the internship offer from ${app.internship.company}? This action cannot be undone.'
        : 'Are you sure you want to withdraw your application for ${app.internship.role} at ${app.internship.company}? This action cannot be undone.';

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            actionTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          content: Text(
            actionMessage,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: AppColors.bodyText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: AppColors.bodyText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ApplicationTrackerStore.instance
                    .updateStatus(app.id, 'Withdrawn');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Application for ${app.internship.company} marked as Withdrawn.',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    backgroundColor: const Color(0xFF64748B),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isOffer ? 'Decline' : 'Withdraw',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show confirmation popup before removing a Withdrawn or Rejected application from Tracker
  void _confirmRemoveApplication(TrackedApplication app) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Remove from Tracker',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          content: Text(
            'Are you sure you want to remove the application for ${app.internship.role} at ${app.internship.company} from your history?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: AppColors.bodyText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: AppColors.bodyText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                final removed =
                    ApplicationTrackerStore.instance.removeFromTracker(app.id);
                if (removed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Application for ${app.internship.company} removed from Tracker.',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      backgroundColor: const Color(0xFF64748B),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Remove',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show detailed application modal when "View Details" is clicked
  void _showApplicationDetailsModal(TrackedApplication app) {
    final statusColor = _getStatusColor(app.status);
    final canWithdraw = app.status == 'Applied' ||
        app.status == 'Under Review' ||
        app.status == 'Interview';
    final canDecline = app.status == 'Offer';
    final canRemove = app.status == 'Withdrawn' || app.status == 'Rejected';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Row: Company Logo + Role & Company + Status Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CompanyLogoWidget(
                        logoKey: app.internship.logoKey,
                        companyName: app.internship.company,
                        brandColor: app.internship.brandColor,
                        size: 48,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.internship.role,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.heading,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              app.internship.company,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.bodyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          app.status,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Dates Info Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date Applied',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.hintText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              app.appliedDate,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.heading,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Last Updated',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.hintText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              app.lastUpdated,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.heading,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Progress Timeline
                  Text(
                    'Application Progress Timeline',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildProgressTracker(app.status),

                  if (app.interviewInfo != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFBFDBFE),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event_note_rounded,
                            color: Color(0xFF2563EB),
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Interview Details',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E40AF),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  app.interviewInfo!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1E3A8A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action Buttons in Details Modal
                  if (canWithdraw || canDecline)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFCBD5E1),
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Close',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.heading,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _confirmWithdrawOrDecline(app);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              canDecline ? 'Decline Offer' : 'Withdraw',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (canRemove)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFCBD5E1),
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Close',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.heading,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _confirmRemoveApplication(app);
                            },
                            icon: const Icon(Icons.delete_outline_rounded, size: 18),
                            label: Text(
                              'Remove',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.heading,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TrackedApplication>>(
      valueListenable: ApplicationTrackerStore.instance,
      builder: (context, allApps, child) {
        final filteredApps = _filterApplications(allApps);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.heading,
                size: 20,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                }
              },
            ),
            title: Text(
              'Application Tracker',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.heading,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                // Subtitle Header
                Text(
                  'Track & manage your internship applications',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.bodyText,
                  ),
                ),
                const SizedBox(height: 16),

                // Top Summary Cards Row (Responsive Grid / Row)
                _buildSummaryCardsRow(allApps),

                const SizedBox(height: 20),

                // Filter Tabs Bar
                _buildFilterTabs(),

                const SizedBox(height: 16),

                // Application Cards List or Empty State
                if (filteredApps.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 56,
                            color: AppColors.hintText.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No applications found',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.heading,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No applications under status "$_selectedFilter".',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.hintText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: filteredApps.map((app) {
                      return _buildApplicationCard(app);
                    }).toList(),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: 2,
            onTap: (int index) {
              if (index == 0 || index == 1) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              } else if (index == 2) {
                return;
              } else if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              } else if (index == 4) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  /// Top Summary Cards displaying count metrics
  Widget _buildSummaryCardsRow(List<TrackedApplication> apps) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 24) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _summaryCard(
              title: 'Applied',
              count: _countByStatus(apps, 'Applied'),
              color: const Color(0xFF2563EB),
              icon: Icons.send_rounded,
              width: cardWidth,
            ),
            _summaryCard(
              title: 'Under Review',
              count: _countByStatus(apps, 'Under Review'),
              color: const Color(0xFF7C3AED),
              icon: Icons.access_time_filled_rounded,
              width: cardWidth,
            ),
            _summaryCard(
              title: 'Interview',
              count: _countByStatus(apps, 'Interview'),
              color: const Color(0xFFEA580C),
              icon: Icons.video_camera_front_rounded,
              width: cardWidth,
            ),
            _summaryCard(
              title: 'Offer',
              count: _countByStatus(apps, 'Offer'),
              color: const Color(0xFF16A34A),
              icon: Icons.workspace_premium_rounded,
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D0141).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Horizontal Filter Tabs
  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              key: Key('filter_$filter'),
              onTap: () {
                setState(() => _selectedFilter = filter);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Text(
                  filter,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.heading,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Application Card showing details, progress tracker, and actions
  Widget _buildApplicationCard(TrackedApplication app) {
    final statusColor = _getStatusColor(app.status);
    final isRemovable = app.status == 'Withdrawn' || app.status == 'Rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D0141).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Logo + Position & Company + Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CompanyLogoWidget(
                logoKey: app.internship.logoKey,
                companyName: app.internship.company,
                brandColor: app.internship.brandColor,
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.internship.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.heading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app.internship.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bodyText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  app.status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Date Info Row: Applied Date & Deadline
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 4),
              Text(
                'Applied: ${app.appliedDate}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.bodyText,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.timer_outlined,
                size: 14,
                color: AppColors.hintText,
              ),
              const SizedBox(width: 4),
              Text(
                'Deadline: ${app.deadline}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.hintText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Clear Progress Tracker Stepper (Applied → Under Review → Interview → Decision)
          _buildProgressTracker(app.status),

          const SizedBox(height: 16),

          // Action Buttons: "View Internship", "View Details", and optional "Remove"
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    showInternshipDetailsSheet(
                      context,
                      app.internship,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFCBD5E1),
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'View Internship',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.heading,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showApplicationDetailsModal(app),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'View Details',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (isRemovable) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _confirmRemoveApplication(app),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFDC2626),
                    size: 20,
                  ),
                  tooltip: 'Remove from Tracker',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Color(0xFFFCA5A5),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// 4-Stage Visual Stepper Line: Applied → Under Review → Interview → Decision
  Widget _buildProgressTracker(String currentStatus) {
    final stages = ['Applied', 'Under Review', 'Interview', 'Decision'];

    int activeIndex = 0;
    if (currentStatus == 'Under Review') {
      activeIndex = 1;
    } else if (currentStatus == 'Interview') {
      activeIndex = 2;
    } else if (currentStatus == 'Offer' ||
        currentStatus == 'Rejected' ||
        currentStatus == 'Withdrawn') {
      activeIndex = 3;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(stages.length, (index) {
          final isCompleted = index <= activeIndex &&
              currentStatus != 'Rejected' &&
              currentStatus != 'Withdrawn';
          final isCurrent = index == activeIndex;
          final isRejected = currentStatus == 'Rejected' && index == 3;
          final isWithdrawn = currentStatus == 'Withdrawn' && index == 3;

          Color nodeColor = const Color(0xFFCBD5E1);
          if (isRejected) {
            nodeColor = const Color(0xFFDC2626);
          } else if (isWithdrawn) {
            nodeColor = const Color(0xFF64748B);
          } else if (isCompleted) {
            nodeColor = AppColors.primaryBlue;
          }

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        color: index == 0
                            ? Colors.transparent
                            : (index <= activeIndex
                                ? AppColors.primaryBlue
                                : const Color(0xFFCBD5E1)),
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isCompleted || isRejected || isWithdrawn
                            ? nodeColor
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: nodeColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: Colors.white,
                              )
                            : (isRejected || isWithdrawn)
                                ? const Icon(
                                    Icons.close_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  )
                                : Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: nodeColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 3,
                        color: index == stages.length - 1
                            ? Colors.transparent
                            : (index < activeIndex
                                ? AppColors.primaryBlue
                                : const Color(0xFFCBD5E1)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  stages[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight:
                        isCurrent ? FontWeight.w800 : FontWeight.w600,
                    color: isCurrent
                        ? AppColors.heading
                        : AppColors.hintText,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
