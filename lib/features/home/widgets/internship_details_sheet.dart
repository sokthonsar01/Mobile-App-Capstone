import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../applications/data/application_tracker_store.dart';
import '../../../shared/page_transitions.dart';
import '../../applications/presentation/application_submitted_screen.dart';
import '../data/internship_model.dart';
import '../data/internship_repository.dart';
import '../viewmodel/internships_viewmodel.dart';
import 'company_logo_widget.dart';

/// Bottom sheet displaying full details for an internship opportunity.
void showInternshipDetailsSheet(
  BuildContext context,
  InternshipOpportunity internship, {
  VoidCallback? onToggleSave,
  bool isSaved = false,
  bool showApplyButton = true,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      return _InternshipDetailsContent(
        internship: internship,
        initialSaved: isSaved,
        onToggleSave: onToggleSave,
        showApplyButton: showApplyButton,
      );
    },
  );
}

class _InternshipDetailsContent extends StatefulWidget {
  final InternshipOpportunity internship;
  final bool initialSaved;
  final VoidCallback? onToggleSave;
  final bool showApplyButton;

  const _InternshipDetailsContent({
    required this.internship,
    required this.initialSaved,
    this.onToggleSave,
    this.showApplyButton = true,
  });

  @override
  State<_InternshipDetailsContent> createState() =>
      _InternshipDetailsContentState();
}

class _InternshipDetailsContentState extends State<_InternshipDetailsContent> {
  late bool _isSaved = widget.initialSaved;
  late InternshipOpportunity _internship = widget.internship;
  bool _isLoadingDetails = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.initialSaved;
    _internship = widget.internship;
    _resolveFullDetails();
  }

  Future<void> _resolveFullDetails() async {
    // 1. Try local cache in InternshipsViewModel first
    if (_internship.id.isNotEmpty) {
      final cached = InternshipsViewModel.instance.internships
          .where((i) =>
              i.id == _internship.id ||
              (i.company.toLowerCase() == _internship.company.toLowerCase() &&
                  i.role.toLowerCase() == _internship.role.toLowerCase()))
          .firstOrNull;
      if (cached != null &&
          cached.requirements.isNotEmpty &&
          cached.description.isNotEmpty) {
        if (mounted) {
          setState(() => _internship = cached);
        }
        return;
      }
    }

    // 2. Fetch live details from backend if ID is valid
    if (_internship.id.isNotEmpty) {
      if (mounted) setState(() => _isLoadingDetails = true);
      final remote = await InternshipRepository.getInternshipById(_internship.id);
      if (remote != null && mounted) {
        setState(() {
          _internship = remote;
          _isLoadingDetails = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  Future<void> _handleApply() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final startTime = DateTime.now();
    final error = await ApplicationTrackerStore.instance.applyToInternship(item: _internship);
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed.inMilliseconds < 650) {
      await Future.delayed(
        Duration(milliseconds: 650 - elapsed.inMilliseconds),
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    Navigator.pop(context);
    Navigator.push(
      context,
      createSmoothPageRoute(
        page: ApplicationSubmittedScreen(
          internship: _internship,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _internship;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Scrollable Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // Top Header Row with Logo and Actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CompanyLogoWidget(
                      logoKey: item.logoKey,
                      companyName: item.company,
                      brandColor: item.brandColor,
                      logoUrl: item.logoUrl,
                      size: 64,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.role,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.heading,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.company,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.category,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isSaved
                            ? Icons.bookmark
                            : Icons.bookmark_border_rounded,
                        color: _isSaved
                            ? AppColors.primaryBlue
                            : AppColors.bodyText,
                        size: 26,
                      ),
                      onPressed: () {
                        setState(() => _isSaved = !_isSaved);
                        widget.onToggleSave?.call();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isSaved
                                  ? 'Saved ${item.role} to your bookmarks'
                                  : 'Removed from bookmarks',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Key Info Grid
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Location',
                  item.location,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.access_time_rounded,
                  'Schedule',
                  item.schedule,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.monetization_on_outlined,
                  'Compensation',
                  '${item.paymentStatus} (${item.stipend})',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  'Application Deadline',
                  item.deadline,
                ),

                const SizedBox(height: 22),
                Row(
                  children: [
                    Text(
                      'About the Internship',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                    if (_isLoadingDetails) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.description.isNotEmpty
                      ? item.description
                      : 'Join ${item.company} as a ${item.role} to gain practical industry experience and work on impactful projects.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.bodyText,
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  'Requirements',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 10),
                if (item.requirements.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Enrolled in or completed degree in a relevant field with a strong desire to learn.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        color: AppColors.bodyText,
                      ),
                    ),
                  )
                else
                  ...item.requirements.map(
                    (req) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Icon(
                              Icons.check_circle_outline_rounded,
                              size: 16,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              req,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                color: AppColors.bodyText,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Bottom Action Bar (hidden when opened from Applications page)
          if (widget.showApplyButton)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Builder(
                  builder: (context) {
                    final isAlreadyApplied = ApplicationTrackerStore.instance.isAlreadyApplied(
                      item.id,
                      company: item.company,
                      role: item.role,
                    );

                    return WideButton(
                      text: isAlreadyApplied ? 'ALREADY APPLIED' : 'APPLY NOW',
                      color: isAlreadyApplied ? const Color(0xFF64748B) : AppColors.primaryBlue,
                      isLoading: _isSubmitting,
                      onPressed: isAlreadyApplied
                          ? () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'You have already applied for this internship.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
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
                          : _handleApply,
                    );
                  },
                ),
              ),
            )
          else
            const SafeArea(
              top: false,
              child: SizedBox(height: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.hintText,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.heading,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
