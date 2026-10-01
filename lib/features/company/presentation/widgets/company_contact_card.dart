import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/app_colors.dart';
import '../../data/company_model.dart';

/// Card showing verified contact and online presence for the company.
class CompanyContactCard extends StatelessWidget {
  final Company company;

  const CompanyContactCard({
    super.key,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
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
            'Contact & Career Information',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 12),
          _buildRow(
            Icons.phone_rounded,
            company.contact.isNotEmpty ? company.contact : 'Not specified',
          ),
          if (company.website != null && company.website!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildRow(Icons.language_rounded, company.website!),
          ],
          const SizedBox(height: 10),
          _buildRow(
            Icons.work_outline_rounded,
            'Industry: ${company.industry}',
          ),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primaryBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              height: 1.45,
              color: AppColors.bodyText,
            ),
          ),
        ),
      ],
    );
  }
}
