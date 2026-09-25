import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../data/internship_model.dart';
import '../presentation/internship_details_screen.dart';
import 'company_logo_widget.dart';

/// Card showing one internship opportunity in the suggestions list.
class InternshipCard extends StatelessWidget {
  final InternshipOpportunity internship;
  final bool isSaved;
  final VoidCallback? onToggleSave;

  const InternshipCard({
    super.key,
    required this.internship,
    this.isSaved = false,
    this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InternshipDetailsScreen(
                  internship: internship,
                  initialSaved: isSaved,
                  onToggleSave: onToggleSave,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Logo
                CompanyLogoWidget(
                  logoKey: internship.logoKey,
                  companyName: internship.company,
                  brandColor: internship.brandColor,
                  size: 66,
                ),
                const SizedBox(width: 12),

                // Internship Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title: "Role at Company"
                      Text(
                        internship.displayTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Location
                      _buildDetailRow(
                        Icons.location_on_rounded,
                        internship.location,
                      ),
                      const SizedBox(height: 3),

                      // Working hours
                      _buildDetailRow(
                        Icons.access_time_filled_rounded,
                        internship.schedule,
                      ),
                      const SizedBox(height: 3),

                      // Payment included
                      _buildDetailRow(
                        Icons.monetization_on_rounded,
                        internship.paymentStatus,
                      ),
                      const SizedBox(height: 3),

                      // Deadline date
                      _buildDetailRow(
                        Icons.calendar_month_rounded,
                        internship.deadline,
                      ),
                      const SizedBox(height: 8),

                      // "View Details" button on the right
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'View Details',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 13,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.bodyText,
            ),
          ),
        ),
      ],
    );
  }
}
