import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../data/internship_model.dart';
import 'company_logo_widget.dart';

/// Bottom sheet displaying full details for an internship opportunity.
void showInternshipDetailsSheet(
  BuildContext context,
  InternshipOpportunity internship, {
  VoidCallback? onToggleSave,
  bool isSaved = false,
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
      );
    },
  );
}

class _InternshipDetailsContent extends StatefulWidget {
  final InternshipOpportunity internship;
  final bool initialSaved;
  final VoidCallback? onToggleSave;

  const _InternshipDetailsContent({
    required this.internship,
    required this.initialSaved,
    this.onToggleSave,
  });

  @override
  State<_InternshipDetailsContent> createState() =>
      _InternshipDetailsContentState();
}

class _InternshipDetailsContentState extends State<_InternshipDetailsContent> {
  late bool _isSaved = widget.initialSaved;

  @override
  Widget build(BuildContext context) {
    final item = widget.internship;

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
                Text(
                  'About the Internship',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
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

          // Bottom Action Bar
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
              child: WideButton(
                text: 'APPLY NOW',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Application started for ${item.displayTitle}!',
                      ),
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  );
                },
              ),
            ),
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
