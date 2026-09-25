import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../data/application_tracker_store.dart';
import '../data/internship_model.dart';
import '../widgets/company_logo_widget.dart';
import 'application_submitted_screen.dart';

/// Screen displaying the full company profile, mission, vision, values, and contact info.
class CompanyProfileScreen extends StatelessWidget {
  final InternshipOpportunity? internship;
  final String companyName;

  const CompanyProfileScreen({
    super.key,
    this.internship,
    this.companyName = 'Hanuman Estate',
  });

  @override
  Widget build(BuildContext context) {
    final item = internship ?? demoInternships.firstWhere(
      (element) => element.id == 'hanuman-06',
      orElse: () => demoInternships.first,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.heading, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          companyName,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.heading,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Company Header Logo Banner
          Center(
            child: Column(
              children: [
                CompanyLogoWidget(
                  logoKey: item.logoKey,
                  companyName: companyName,
                  brandColor: item.brandColor,
                  size: 88,
                ),
                const SizedBox(height: 12),
                Text(
                  companyName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real Estate Development & Investment',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Company Profile Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
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
                  'Hanuman Estate is a leading real estate developer and investor based in Phnom Penh. Established by a management team with over 15 years of experience in the Cambodian market, the company operates under the "Hanuman" umbrella brand.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    height: 1.55,
                    color: AppColors.bodyText,
                  ),
                ),
                const SizedBox(height: 14),

                // Bullet Points
                _buildBulletPoint(
                  'Mission:',
                  'To improve the well-being of Cambodians by developing projects that go beyond simple buildings to create better living standards and a better society.',
                ),
                const SizedBox(height: 10),
                _buildBulletPoint(
                  'Vision:',
                  'To set a new international standard for real estate development in Cambodia.',
                ),
                const SizedBox(height: 10),
                _buildBulletPoint(
                  'Core Values:',
                  'The company operates under three pillars: Great Home, Great Lifestyle, and Great Prosperity.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 3. Contact & Career Information Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
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
                _buildContactRow(
                  Icons.location_on_rounded,
                  'Headquarters: Building No.33, Samdech Penn Nouth Street (289), Toul Kork District, Phnom Penh.',
                ),
                const SizedBox(height: 10),
                _buildContactRow(
                  Icons.email_rounded,
                  'Recruitment Email: jobs@hanumanestate.com.kh',
                ),
                const SizedBox(height: 10),
                _buildContactRow(
                  Icons.mail_outline_rounded,
                  'General Inquiries: info@hanumanestate.com.kh',
                ),
                const SizedBox(height: 10),
                _buildContactRow(
                  Icons.phone_rounded,
                  'Contact Numbers: 098 339 339 / 096 339 339',
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // 4. Apply Button
          ElevatedButton(
            onPressed: () {
              ApplicationTrackerStore.instance.applyForInternship(item);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApplicationSubmittedScreen(
                    internship: item,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              'Apply Now',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String label, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.5,
                color: AppColors.bodyText,
              ),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
                TextSpan(text: content),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
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
