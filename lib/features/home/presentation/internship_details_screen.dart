import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../messages/presentation/chat_screen.dart';
import '../../profile/data/user_profile_model.dart';
import '../data/internship_model.dart';
import '../widgets/company_logo_widget.dart';
import 'application_submitted_screen.dart';
import 'company_profile_screen.dart';

/// Modern, sleek Internship Details screen.
/// Features a hero promotional poster, applicant matching score,
/// interactive segmented tabs (Overview, Requirements, Company),
/// and a sticky action bar with chat, bookmark, and Apply CTA.
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

class _InternshipDetailsScreenState extends State<InternshipDetailsScreen>
    with SingleTickerProviderStateMixin {
  late bool _isSaved;
  late TabController _tabController;
  bool _isMatchExpanded = true;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.initialSaved;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSave() {
    setState(() => _isSaved = !_isSaved);
    widget.onToggleSave?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSaved
              ? 'Saved ${widget.internship.role} to bookmarks'
              : 'Removed from bookmarks',
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
      backgroundColor: const Color(0xFFF8FAFC),
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
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.heading,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing internship link...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: _isSaved ? AppColors.primaryBlue : AppColors.heading,
              size: 24,
            ),
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Hero Promotional Poster Banner
          _buildHeroPoster(item),

          const SizedBox(height: 16),

          // 2. Main Title & Company Header Card
          _buildCompanyHeader(item),

          const SizedBox(height: 14),

          // 3. 4-Pill Quick Stats Row
          _buildQuickStatsRow(item),

          const SizedBox(height: 16),

          // 4. Personalized Candidate Match Card (Tailored to Sombo & CADT)
          _buildPersonalizedMatchCard(item),

          const SizedBox(height: 18),

          // 5. Modern Segmented Tab Bar
          _buildSegmentedTabBar(),

          const SizedBox(height: 16),

          // 6. Tab Content Container
          _buildTabContent(item),
        ],
      ),
      bottomSheet: _buildBottomActionBar(item),
    );
  }

  /// 1. Hero Poster with Floating Category & Payment Badges
  Widget _buildHeroPoster(InternshipOpportunity item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D0141).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 750 / 350,
              child: item.posterAssetPath.isNotEmpty
                  ? Image.asset(
                      item.posterAssetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallbackBanner(item),
                    )
                  : _buildFallbackBanner(item),
            ),

            // Top Badges Overlay
            Positioned(
              top: 12,
              left: 12,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      item.category,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: item.brandColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.paymentStatus,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
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
      ),
    );
  }

  Widget _buildFallbackBanner(InternshipOpportunity item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [item.brandColor, item.brandColor.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          item.displayTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// 2. Company & Role Header Card
  Widget _buildCompanyHeader(InternshipOpportunity item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CompanyLogoWidget(
                logoKey: item.logoKey,
                companyName: item.company,
                brandColor: item.brandColor,
                size: 52,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.company,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.bodyText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF2563EB),
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.role,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.heading,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: AppColors.hintText,
              ),
              const SizedBox(width: 4),
              Text(
                item.location,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.bodyText,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.schedule_rounded,
                size: 15,
                color: AppColors.hintText,
              ),
              const SizedBox(width: 4),
              Text(
                'Deadline: ${item.deadline}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3. 4-Pill Quick Stats
  Widget _buildQuickStatsRow(InternshipOpportunity item) {
    return Row(
      children: [
        Expanded(
          child: _buildStatPill(
            icon: Icons.payments_rounded,
            color: const Color(0xFF10B981),
            label: 'Stipend',
            value: item.stipend.contains('/') ? item.stipend.split('/').first.trim() : item.stipend,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatPill(
            icon: Icons.calendar_today_rounded,
            color: const Color(0xFF2563EB),
            label: 'Duration',
            value: '3 - 6 Mos',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatPill(
            icon: Icons.work_outline_rounded,
            color: const Color(0xFF8B5CF6),
            label: 'Schedule',
            value: item.schedule,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatPill(
            icon: Icons.auto_awesome_rounded,
            color: const Color(0xFFF59E0B),
            label: 'Match',
            value: '95%',
          ),
        ),
      ],
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.hintText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.heading,
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Personalized Candidate Match Card (Tailored to Sombo & CADT)
  Widget _buildPersonalizedMatchCard(InternshipOpportunity item) {
    final profile = currentDemoProfile;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isMatchExpanded = !_isMatchExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '95% Match with Your Profile',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E40AF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tailored for ${profile.fullName} (${profile.major.split('&').first.trim()})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isMatchExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF1E40AF),
                  ),
                ],
              ),
            ),
          ),

          if (_isMatchExpanded) ...[
            const Divider(height: 1, color: Color(0xFFBFDBFE)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                children: [
                  _buildMatchCriterion(
                    'Academic Major Aligned',
                    '${profile.major} at CADT',
                    true,
                  ),
                  const SizedBox(height: 8),
                  _buildMatchCriterion(
                    'CV / Resume Attached',
                    profile.cvFileName,
                    true,
                  ),
                  const SizedBox(height: 8),
                  _buildMatchCriterion(
                    'Skills Matched',
                    'Flutter, Dart, Mobile Dev, APIs (4/4 Match)',
                    true,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchCriterion(String title, String subtitle, bool isMatched) {
    return Row(
      children: [
        Icon(
          isMatched ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: isMatched ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
          size: 16,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 5. Segmented Tab Bar
  Widget _buildSegmentedTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() {}),
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.bodyText,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Requirements'),
          Tab(text: 'Company'),
        ],
      ),
    );
  }

  /// 6. Tab Content Container
  Widget _buildTabContent(InternshipOpportunity item) {
    switch (_tabController.index) {
      case 0:
        return _buildOverviewTab(item);
      case 1:
        return _buildRequirementsTab(item);
      case 2:
        return _buildCompanyTab(item);
      default:
        return _buildOverviewTab(item);
    }
  }

  Widget _buildOverviewTab(InternshipOpportunity item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About the Role',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.bodyText,
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Key Responsibilities',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 10),
          _buildCheckItem('Assist engineering team with core features & bug fixes.'),
          _buildCheckItem('Participate in daily standups and agile sprint reviews.'),
          _buildCheckItem('Write clean, maintainable, and well-tested code.'),
          _buildCheckItem('Collaborate with designers, PMs, and senior mentors.'),

          const SizedBox(height: 18),
          Text(
            'Perks & Benefits',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 10),
          _buildPerkItem(Icons.verified_outlined, 'Certificate of Completion & Letter of Recommendation'),
          _buildPerkItem(Icons.person_pin_circle_outlined, '1-on-1 Mentorship from Senior Tech Leads'),
          _buildPerkItem(Icons.card_giftcard_rounded, 'Monthly stipend allowance + Free snacks & coffee'),
          _buildPerkItem(Icons.trending_up_rounded, 'High opportunity for full-time junior job offer'),
        ],
      ),
    );
  }

  Widget _buildRequirementsTab(InternshipOpportunity item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requirements & Eligibility',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 10),
          ...item.requirements.map((req) => _buildCheckItem(req)),

          const SizedBox(height: 18),
          Text(
            'Required Skills & Tools',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Flutter',
              'Dart',
              'Mobile Dev',
              'REST APIs',
              'Git / GitHub',
              'UI/UX Basics',
              'Teamwork',
            ].map((skill) {
              return Chip(
                label: Text(
                  skill,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
                backgroundColor: const Color(0xFFEFF6FF),
                side: const BorderSide(color: Color(0xFFDBEAFE)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyTab(InternshipOpportunity item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CompanyLogoWidget(
                logoKey: item.logoKey,
                companyName: item.company,
                brandColor: item.brandColor,
                size: 56,
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
                    Text(
                      '${item.category} Industry • Phnom Penh',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.hintText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'About ${item.company}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.company} is one of the leading organizations in Cambodia offering structured internship programs designed to groom emerging student talents into high-performing industry professionals.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.5,
              color: AppColors.bodyText,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompanyProfileScreen(internship: item),
                ),
              );
            },
            icon: const Icon(Icons.business_rounded, size: 18),
            label: Text(
              'View Company Profile & Openings',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.primaryBlue),
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 12,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.4,
                color: AppColors.bodyText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerkItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.bodyText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky Bottom Action Bar
  Widget _buildBottomActionBar(InternshipOpportunity item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.15),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Chat with recruiter button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.heading,
                  size: 22,
                ),
                tooltip: 'Chat with Recruiter',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        contactName: '${item.company} Careers',
                        avatarAsset: item.logoAssetPath,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),

            // Bookmark button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                icon: Icon(
                  _isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: _isSaved ? AppColors.primaryBlue : AppColors.heading,
                  size: 24,
                ),
                tooltip: 'Bookmark',
                onPressed: _toggleSave,
              ),
            ),
            const SizedBox(width: 12),

            // Large vibrant Apply CTA button
            Expanded(
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
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Apply Now',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
