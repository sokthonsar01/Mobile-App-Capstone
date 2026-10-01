import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/app_colors.dart';
import '../../../home/widgets/company_logo_widget.dart';
import '../../data/company_model.dart';

/// Header widget rendering company logo, verification badge, title, and industry.
class CompanyProfileHeader extends StatelessWidget {
  final Company company;
  final String logoKey;
  final Color brandColor;

  const CompanyProfileHeader({
    super.key,
    required this.company,
    this.logoKey = 'default',
    this.brandColor = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _buildLogo(),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                company.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.heading,
                ),
              ),
              if (company.verified) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            company.industry.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: AppColors.bodyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return CompanyLogoWidget(
      logoKey: logoKey,
      companyName: company.name,
      brandColor: brandColor,
      logoUrl: company.logoUrl,
      size: 88,
    );
  }
}
