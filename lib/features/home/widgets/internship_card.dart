import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../data/internship_model.dart';
import '../presentation/internship_details_screen.dart';
import 'company_logo_widget.dart';

/// Clean, minimal, modern internship listing card.
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
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D0141).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header: Company Logo + Company Name & Role Title + Bookmark Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CompanyLogoWidget(
                      logoKey: internship.logoKey,
                      companyName: internship.company,
                      brandColor: internship.brandColor,
                      size: 44,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  internship.company,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.heading,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: internship.brandColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  internship.category,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: internship.brandColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            internship.role,
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
                    if (onToggleSave != null)
                      GestureDetector(
                        onTap: onToggleSave,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isSaved
                                ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                : AppColors.lightFill,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 18,
                            color: isSaved
                                ? AppColors.primaryBlue
                                : AppColors.hintText,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // 2. Short Description with "See more"
                RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppColors.heading,
                    ),
                    children: [
                      TextSpan(
                        text: _getCaptionText(internship),
                      ),
                      const TextSpan(text: ' ... '),
                      TextSpan(
                        text: 'See more',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 3. Internship Card Poster Image
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: AspectRatio(
                      aspectRatio: 750 / 350,
                      child: Image.asset(
                        internship.posterAssetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: internship.brandColor.withValues(alpha: 0.15),
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              color: internship.brandColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 4. Footer Bar: View Details Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Details',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ],
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

  String _getCaptionText(InternshipOpportunity item) {
    if (item.description.isNotEmpty) {
      if (item.description.length > 70) {
        return item.description.substring(0, 70).trim();
      }
      return item.description;
    }
    return 'Grow Your Career with ${item.company}!✨';
  }
}



