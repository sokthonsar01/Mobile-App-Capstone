import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/app_navigation.dart';
import '../../../shared/theme/app_theme_controller.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../data/application_tracker_store.dart';
import '../../home/data/internship_model.dart';
import '../../home/widgets/company_logo_widget.dart';
import '../../home/presentation/home_screen.dart';

/// Screen displaying submitted application status, review stepper, and submission attachments.
class ApplicationDetailsScreen extends StatefulWidget {
  final InternshipOpportunity? internship;

  const ApplicationDetailsScreen({
    super.key,
    this.internship,
  });

  @override
  State<ApplicationDetailsScreen> createState() =>
      _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends State<ApplicationDetailsScreen> {
  bool _isWithdrawn = false;

  void _confirmWithdraw() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Withdraw Application',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          content: Text(
            'Are you sure you want to withdraw your application for this position? This action cannot be undone.',
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
                setState(() => _isWithdrawn = true);
                final item = widget.internship;
                if (item != null) {
                  final tracked = ApplicationTrackerStore.instance.value
                      .where((a) => a.internship.id == item.id)
                      .firstOrNull;
                  if (tracked != null) {
                    ApplicationTrackerStore.instance
                        .updateStatus(tracked.id, 'Withdrawn');
                  }
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Application withdrawn successfully.',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: const Color(0xFFD92D20),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD92D20),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Withdraw',
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

  @override
  Widget build(BuildContext context) {
    final item = widget.internship ?? demoInternships.firstWhere(
      (e) => e.id == 'hanuman-06',
      orElse: () => demoInternships.first,
    );
    final tracked = ApplicationTrackerStore.instance.value
        .where((a) => a.internship.id == item.id)
        .firstOrNull;
    final appliedDate = tracked?.appliedDate ??
        ApplicationTrackerStore.formatDateTime(DateTime.now());
    final currentStatus =
        _isWithdrawn ? 'Withdrawn' : (tracked?.status ?? 'Applied');

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.instance.themeModeNotifier,
      builder: (context, currentMode, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.heading,
                size: 20,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            title: Text(
              'Application Details',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.heading,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.home_outlined,
                  color: AppColors.heading,
                  size: 24,
                ),
                tooltip: 'Back to Home',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.link_rounded,
                  color: AppColors.heading,
                  size: 24,
                ),
                tooltip: 'Copy application details',
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: 'My application: ${item.role} at ${item.company}\n'
                          'Applied on: $appliedDate\n'
                          'Status: $currentStatus',
                    ),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Application details copied to clipboard',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Company and Role Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CompanyLogoWidget(
                  logoKey: item.logoKey,
                  companyName: item.company,
                  brandColor: item.brandColor,
                  size: 68,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.company,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• ${item.role}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bodyText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Applied on: $appliedDate',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.hintText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2. Application Progress Stepper Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stepper Visual
                _buildStepper(),

                const SizedBox(height: 20),

                // Current Stage Info
                Text(
                  'Current Stage: $currentStatus',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: _isWithdrawn
                        ? const Color(0xFFD92D20)
                        : AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isWithdrawn
                      ? 'You have withdrawn your application for this role.'
                      : "Your profile is being reviewed by the employer. You'll be notified if you are shortlisted for the next step.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 3. Your Submission Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Submission:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 14),

                // CV attachment row
                Row(
                  children: [
                    Text(
                      'CV:  ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Color(0xFFD92D20),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Resume.pdf',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.heading,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD92D20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '70 MB',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Cover Letter
                Text(
                  'Cover Letter: Not Provided (Optional)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.bodyText,
                  ),
                ),

                const SizedBox(height: 8),

                // Portfolio link
                Text(
                  'Portfolio link: Not Provided (Optional)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.bodyText,
                  ),
                ),

                const SizedBox(height: 16),

                // Small Disclaimer Note
                Text(
                  'A CV is sufficient for most applications. You may include additional documents to strengthen your profile, but they are not required.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.hintText,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                // Withdraw Button
                if (!_isWithdrawn)
                  ElevatedButton(
                    onPressed: _confirmWithdraw,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD92D20),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Withdraw',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Back to Home Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.home_rounded, size: 20),
            label: Text(
              'Back to Home',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: 2,
            onTap: (int index) => navigateToAppTab(context, 2, index),
          ),
        );
      },
    );
  }

  /// 5-Step Application Stepper Tracker
  Widget _buildStepper() {
    final stages = [
      {'name': 'Applied', 'state': 'done'},
      {'name': 'Under Review', 'state': 'current'},
      {'name': 'Shortlisted', 'state': 'future'},
      {'name': 'Interviewed', 'state': 'future'},
      {'name': 'Final Decision', 'state': 'future'},
    ];

    return Column(
      children: [
        Row(
          children: List.generate(stages.length * 2 - 1, (index) {
            if (index.isOdd) {
              final stepIndex = index ~/ 2;
              final isPassed = stepIndex < 1;
              return Expanded(
                child: Container(
                  height: 2,
                  color: isPassed
                      ? AppColors.primaryBlue
                      : const Color(0xFFD1D5DB),
                ),
              );
            }

            final stepIndex = index ~/ 2;
            final stage = stages[stepIndex];
            final state = stage['state'];

            return Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: state == 'done'
                    ? AppColors.primaryBlue
                    : state == 'current'
                        ? Colors.white
                        : const Color(0xFFE5E7EB),
                border: state == 'current'
                    ? Border.all(color: AppColors.primaryBlue, width: 2)
                    : null,
              ),
              child: Center(
                child: state == 'done'
                    ? const Icon(Icons.check, color: Colors.white, size: 13)
                    : state == 'current'
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stages.map((stage) {
            final isCurrent = stage['state'] == 'current';
            final isDone = stage['state'] == 'done';

            return Expanded(
              child: Text(
                stage['name']!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight:
                      (isCurrent || isDone) ? FontWeight.w700 : FontWeight.w500,
                  color: (isCurrent || isDone)
                      ? AppColors.heading
                      : AppColors.hintText,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
