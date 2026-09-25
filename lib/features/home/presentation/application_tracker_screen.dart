import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../data/internship_model.dart';
import '../widgets/company_logo_widget.dart';
import '../widgets/internship_details_sheet.dart';
import 'home_screen.dart';

/// Application model representing a student's tracked application.
class TrackedApplication {
  final String id;
  final InternshipOpportunity internship;
  final String appliedDate;
  final String deadline;
  String status;

  TrackedApplication({
    required this.id,
    required this.internship,
    required this.appliedDate,
    required this.deadline,
    required this.status,
  });
}

/// The main Application Tracker Page for students to track every internship applied for.
class ApplicationTrackerScreen extends StatefulWidget {
  const ApplicationTrackerScreen({super.key});

  @override
  State<ApplicationTrackerScreen> createState() =>
      _ApplicationTrackerScreenState();
}

class _ApplicationTrackerScreenState extends State<ApplicationTrackerScreen> {
  String _selectedFilter = 'All';

  // Sample applications dataset using demoInternships
  late List<TrackedApplication> _applications;

  final List<String> _filters = [
    'All',
    'Applied',
    'Under Review',
    'Interview',
    'Offer',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _applications = [
      TrackedApplication(
        id: 'app-01',
        internship: demoInternships.firstWhere(
          (e) => e.logoKey == 'chip_mong',
          orElse: () => demoInternships[0],
        ),
        appliedDate: 'Jan 15, 2026',
        deadline: 'Feb 14, 2026',
        status: 'Under Review',
      ),
      TrackedApplication(
        id: 'app-02',
        internship: demoInternships.firstWhere(
          (e) => e.logoKey == 'canadia',
          orElse: () => demoInternships[1],
        ),
        appliedDate: 'Jan 20, 2026',
        deadline: 'Feb 23, 2026',
        status: 'Interview',
      ),
      TrackedApplication(
        id: 'app-03',
        internship: demoInternships.firstWhere(
          (e) => e.logoKey == 'cellcard',
          orElse: () => demoInternships[2],
        ),
        appliedDate: 'Jan 10, 2026',
        deadline: 'Feb 14, 2026',
        status: 'Offer',
      ),
      TrackedApplication(
        id: 'app-04',
        internship: demoInternships.firstWhere(
          (e) => e.logoKey == 'aba',
          orElse: () => demoInternships[3],
        ),
        appliedDate: 'Feb 01, 2026',
        deadline: 'Feb 14, 2026',
        status: 'Applied',
      ),
      TrackedApplication(
        id: 'app-05',
        internship: demoInternships.firstWhere(
          (e) => e.logoKey == 'smart',
          orElse: () => demoInternships[4],
        ),
        appliedDate: 'Jan 05, 2026',
        deadline: 'Feb 14, 2026',
        status: 'Rejected',
      ),
    ];
  }

  // Count helper functions for summary cards
  int _countByStatus(String status) {
    return _applications.where((app) => app.status == status).length;
  }

  List<TrackedApplication> get _filteredApplications {
    if (_selectedFilter == 'All') {
      return _applications;
    }
    return _applications
        .where((app) => app.status == _selectedFilter)
        .toList();
  }

  void _updateStatus(TrackedApplication app, String newStatus) {
    setState(() {
      app.status = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Status updated to "$newStatus" for ${app.internship.company}',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor: _getStatusColor(newStatus),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showUpdateStatusModal(TrackedApplication app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: SafeArea(
            top: false,
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
                Text(
                  'Update Application Status',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select the current status for ${app.internship.role} at ${app.internship.company}:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.bodyText,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    'Applied',
                    'Under Review',
                    'Interview',
                    'Offer',
                    'Rejected',
                  ].map((status) {
                    final isSelected = app.status == status;
                    final color = _getStatusColor(status);

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _updateStatus(app, status);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color
                              : color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : color,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
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
      default:
        return AppColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps = _filteredApplications;

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
            _buildSummaryCardsRow(),

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
  }

  /// Top Summary Cards displaying count metrics
  Widget _buildSummaryCardsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 24) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _summaryCard(
              title: 'Applied',
              count: _countByStatus('Applied'),
              color: const Color(0xFF2563EB),
              icon: Icons.send_rounded,
              width: cardWidth,
            ),
            _summaryCard(
              title: 'Under Review',
              count: _countByStatus('Under Review'),
              color: const Color(0xFF7C3AED),
              icon: Icons.access_time_filled_rounded,
              width: cardWidth,
            ),
            _summaryCard(
              title: 'Interview',
              count: _countByStatus('Interview'),
              color: const Color(0xFFEA580C),
              icon: Icons.video_camera_front_rounded,
              width: cardWidth,
            ),
            _summaryCard(
              title: 'Offer',
              count: _countByStatus('Offer'),
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

          // Action Buttons: "View Internship" & "Update Status"
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
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showUpdateStatusModal(app),
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
                    'Update Status',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
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
    } else if (currentStatus == 'Offer' || currentStatus == 'Rejected') {
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
          final isCompleted = index <= activeIndex && currentStatus != 'Rejected';
          final isCurrent = index == activeIndex;
          final isRejected = currentStatus == 'Rejected' && index == 3;

          Color nodeColor = const Color(0xFFCBD5E1);
          if (isRejected) {
            nodeColor = const Color(0xFFDC2626);
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
                        color: isCompleted || isRejected
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
                            : isRejected
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
