import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/app_colors.dart';
import '../../data/company_model.dart';

/// Card displaying company overview and description fetched from the backend.
class CompanyDetailsCard extends StatelessWidget {
  final Company company;

  const CompanyDetailsCard({
    super.key,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    final description = (company.description != null &&
            company.description!.trim().isNotEmpty)
        ? company.description!.trim()
        : '${company.name} is registered under the ${company.industry} industry on Interna.';

    return Container(
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
            'Company Profile',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.55,
              color: AppColors.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}
