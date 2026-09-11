import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../data/internship_model.dart';
import '../widgets/company_logo_widget.dart';
import 'application_submitted_screen.dart';
import 'company_profile_screen.dart';

/// Screen displaying the full Internship Details, Matching Percentage,
/// Applicant Information, Internship Specifications, and Company Profile shortcut.
class InternshipDetailsScreen extends StatefulWidget {
  final InternshipOpportunity internship;
  final bool initialSaved;
  final VoidCallback? onToggleSave;

  const InternshipDetailsScreen({
    super.key,
    required this.internship,
    this.initialSaved = false,
    this.onToggleSave,
  });

  @override
  State<InternshipDetailsScreen> createState() =>
      _InternshipDetailsScreenState();
}

class _InternshipDetailsScreenState extends State<InternshipDetailsScreen> {
  late bool _isSaved;
  bool _isInfoExpanded = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.initialSaved;
  }

  void _toggleSave() {
    setState(() => _isSaved = !_isSaved);
    widget.onToggleSave?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSaved ? 'Internship saved to your bookmarks' : 'Removed from bookmarks',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.internship;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.heading,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Internship Details',
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
              _isSaved ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _isSaved ? const Color(0xFFFFB300) : AppColors.heading,
              size: 26,
            ),
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Matching Percentage Card (90%)
          _buildMatchingPercentageCard(),

          const SizedBox(height: 14),

          // 2. Your Information Expandable Accordion
          _buildYourInformationAccordion(),

          const SizedBox(height: 14),

          // 3. Internship Information Container Card
          _buildInternshipInfoCard(item),

          const SizedBox(height: 14),

          // 4. Company Profile Shortcut Card
          _buildCompanyProfileCard(item),

          const SizedBox(height: 80),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
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
        ),
      ),
    );
  }

  /// 1. Matching Percentage Card with Progress Bar
  Widget _buildMatchingPercentageCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.16)),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.bodyText,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Matching Percentage: 90%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.heading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 90% Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 12,
              child: LinearProgressIndicator(
                value: 0.90,
                backgroundColor: const Color(0xFFDDE6FF),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. "Your information" Accordion
  Widget _buildYourInformationAccordion() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Blue Accordion Header
          GestureDetector(
            onTap: () {
              setState(() => _isInfoExpanded = !_isInfoExpanded);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(15),
                  bottom: _isInfoExpanded
                      ? Radius.zero
                      : const Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your information',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    _isInfoExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (_isInfoExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileRow('Full Name', 'Max Verstappen'),
                  _buildProfileRow('Email', 'maxverstappen1@gmail.com'),
                  _buildProfileRow('University', 'Paragon International University'),
                  _buildProfileRow('Major', 'Data Science & Analytics'),
                  _buildProfileRow('GPA', '3.85 / 4.0'),
                  _buildProfileRow('Top Skills', 'Python, SQL, Excel, Business Analytics'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.hintText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.heading,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Internship Information Container Card
  Widget _buildInternshipInfoCard(InternshipOpportunity item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.16)),
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
          // Blue Top Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Text(
              'Internship Information',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          // Content body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2-Column Grid (Role & Duration)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInfoBlock(
                        'Target Role:',
                        'Data Science Intern\nBusiness/ BA Intern',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoBlock(
                        'Internship Duration:',
                        '3 Months\nStart: March 2026',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 2-Column Grid (Compensation & Working Arrangement)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInfoBlock(
                        'Compensation:',
                        '\$200 / Month\nPerformance-based allowance',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoBlock(
                        'Working Arrangement:',
                        'Part-time\nFlexible schedule',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Responsibilities
                Text(
                  'Responsibilities:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 6),
                _buildBulletPoint('Assist with data cleaning & analysis'),
                _buildBulletPoint('Support reporting & dashboards'),
                _buildBulletPoint('Collaborate with senior analysts'),

                const SizedBox(height: 14),

                // Requirements
                Text(
                  'Requirements:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 6),
                _buildBulletPoint('Basic Python & Excel'),
                _buildBulletPoint('University student or fresh graduate'),
                _buildBulletPoint('Willing to learn'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: AppColors.heading,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.35,
            color: AppColors.bodyText,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                height: 1.35,
                color: AppColors.bodyText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Company Profile Shortcut Card
  Widget _buildCompanyProfileCard(InternshipOpportunity item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompanyProfileScreen(
              internship: item,
              companyName: item.company,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.16)),
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
              size: 58,
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
                  const SizedBox(height: 2),
                  Text(
                    'View Company Profile & Insights',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.hintText,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
