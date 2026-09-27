import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/theme/app_theme_controller.dart';
import '../../messages/presentation/chat_screen.dart';
import '../../profile/data/user_profile_model.dart';
import '../../saved/data/saved_internships_store.dart';
import '../data/internship_model.dart';
import '../widgets/company_logo_widget.dart';
import 'application_submitted_screen.dart';
import 'company_profile_screen.dart';

/// Modern, sleek, and high-impact Internship Details screen.
/// Designed for high visual appeal, responsive layout with zero pixel overflows,
/// comprehensive candidate match integration, and seamless application flow.
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
  bool _isMatchExpanded = false;

  @override
  void initState() {
    super.initState();
    _isSaved = SavedInternshipsStore.instance.isSaved(widget.internship.id) ||
        widget.initialSaved;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSave() {
    SavedInternshipsStore.instance.toggleSave(widget.internship.id);
    setState(() {
      _isSaved = SavedInternshipsStore.instance.isSaved(widget.internship.id);
    });
    widget.onToggleSave?.call();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSaved
              ? 'Saved "${widget.internship.role}" to bookmarks'
              : 'Removed from bookmarks',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.heading,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.internship;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.instance.themeModeNotifier,
      builder: (context, currentMode, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
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
                  Icons.share_outlined,
                  color: AppColors.heading,
                  size: 22,
                ),
                tooltip: 'Share Opportunity',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Link copied for ${item.role} at ${item.company}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13),
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                tooltip: 'Save Bookmark',
                onPressed: _toggleSave,
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. Promotional Card Poster (Clean presentation)
              _buildHeroPoster(item),

              const SizedBox(height: 14),

              // 2. Company & Role Header Card (Guaranteed no overflow)
              _buildCompanyHeader(item),

              const SizedBox(height: 14),

              // 3. 2x2 Key Information Grid (Spacious, no truncated text)
              _buildKeyStatsGrid(item),

              const SizedBox(height: 14),

              // 4. Candidate Match Card (Tailored to Chhouen Ratanaksombo & CADT)
              _buildPersonalizedMatchCard(item),

              const SizedBox(height: 16),

              // 5. Modern Segmented Tab Bar
              _buildSegmentedTabBar(),

              const SizedBox(height: 14),

              // 6. Tab Content Container
              _buildTabContent(item),
            ],
          ),
          bottomSheet: _buildBottomActionBar(item),
        );
      },
    );
  }

  /// 1. Hero Promotional Poster (Clean, crisp aspect ratio)
  Widget _buildHeroPoster(InternshipOpportunity item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
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
      ),
    );
  }

  Widget _buildFallbackBanner(InternshipOpportunity item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [item.brandColor, item.brandColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            item.displayTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// 2. Company & Role Header Card (Robust wrap layout, zero overflow)
  Widget _buildCompanyHeader(InternshipOpportunity item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
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
          // Logo + Role Title + Company
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    Text(
                      item.role,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.heading,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.company,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
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
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Metadata Badges (Responsive Wrap prevents ANY overflow)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHeaderTag(
                icon: Icons.location_on_rounded,
                text: 'Phnom Penh, Cambodia',
                color: const Color(0xFF475569),
                bgColor: const Color(0xFFF1F5F9),
              ),
              _buildHeaderTag(
                icon: Icons.category_rounded,
                text: item.category,
                color: AppColors.primaryBlue,
                bgColor: const Color(0xFFEFF6FF),
              ),
              _buildHeaderTag(
                icon: Icons.event_rounded,
                text: 'Closes ${item.deadline}',
                color: const Color(0xFFDC2626),
                bgColor: const Color(0xFFFEF2F2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTag({
    required IconData icon,
    required String text,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 3. 2x2 Key Stats Grid (Spacious, easy to read on all phone sizes)
  Widget _buildKeyStatsGrid(InternshipOpportunity item) {
    return Row(
      children: [
        // Left Column (Stipend + Schedule)
        Expanded(
          child: Column(
            children: [
              _buildStatCard(
                icon: Icons.payments_rounded,
                iconColor: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
                label: 'Monthly Stipend',
                value: item.stipend.contains('/')
                    ? item.stipend
                    : '${item.stipend} / month',
              ),
              const SizedBox(height: 10),
              _buildStatCard(
                icon: Icons.work_outline_rounded,
                iconColor: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF5F3FF),
                label: 'Work Arrangement',
                value: '${item.schedule} (Flexible)',
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Right Column (Duration + Match Score)
        Expanded(
          child: Column(
            children: [
              _buildStatCard(
                icon: Icons.calendar_today_rounded,
                iconColor: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                label: 'Duration',
                value: '3 - 6 Months',
              ),
              const SizedBox(height: 10),
              _buildStatCard(
                icon: Icons.verified_outlined,
                iconColor: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                label: 'Candidate Match',
                value: '95% Compatibility',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.hintText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Personalized Candidate Match Card
  Widget _buildPersonalizedMatchCard(InternshipOpportunity item) {
    final profile = currentDemoProfile;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.isDark
            ? const Color(0xFF1E3A8A).withValues(alpha: 0.25)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.isDark
              ? const Color(0xFF1E40AF)
              : const Color(0xFFBFDBFE),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isMatchExpanded = !_isMatchExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.school_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Profile Match: 95% Compatibility',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E40AF),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Aligned with ${profile.fullName} (CADT)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
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
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          if (_isMatchExpanded) ...[
            const Divider(height: 1, color: Color(0xFFBFDBFE)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                children: [
                  _buildMatchCriterion(
                    'Academic Background',
                    '${profile.major} (CADT)',
                    true,
                  ),
                  const SizedBox(height: 6),
                  _buildMatchCriterion(
                    'Resume Document',
                    profile.cvFileName,
                    true,
                  ),
                  const SizedBox(height: 6),
                  _buildMatchCriterion(
                    'Skills Fit',
                    'Mobile Dev, APIs, Problem Solving (High Match)',
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
          size: 15,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              Flexible(
                child: Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF475569),
                  ),
                  overflow: TextOverflow.ellipsis,
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
        color: AppColors.isDark
            ? const Color(0xFF334155)
            : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() {}),
        indicator: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About the Role',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.5,
              color: AppColors.bodyText,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Key Responsibilities',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 10),
          _buildCheckItem('Assist engineering team with core features & bug fixes.'),
          _buildCheckItem('Participate in daily standups and agile sprint reviews.'),
          _buildCheckItem('Write clean, maintainable, and well-tested code.'),
          _buildCheckItem('Collaborate with designers, PMs, and senior mentors.'),

          const SizedBox(height: 16),
          Text(
            'Perks & Benefits',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requirements & Eligibility',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 10),
          ...item.requirements.map((req) => _buildCheckItem(req)),

          const SizedBox(height: 16),
          Text(
            'Required Skills & Tools',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
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
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Text(
                  skill,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.company,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.heading,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${item.category} Industry • Phnom Penh',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppColors.hintText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'About ${item.company}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.company} is one of the leading organizations in Cambodia offering structured internship programs designed to groom emerging student talents into high-performing industry professionals.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.bodyText,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompanyProfileScreen(internship: item),
                ),
              );
            },
            icon: const Icon(Icons.business_rounded, size: 16),
            label: Text(
              'View Company Profile & Openings',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.primaryBlue),
              minimumSize: const Size.fromHeight(44),
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
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 11,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
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
          Icon(icon, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.cardBorder,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
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
                color: AppColors.isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.heading,
                  size: 20,
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
            const SizedBox(width: 8),

            // Bookmark button
            Container(
              decoration: BoxDecoration(
                color: AppColors.isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  _isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: _isSaved ? AppColors.primaryBlue : AppColors.heading,
                  size: 22,
                ),
                tooltip: 'Bookmark',
                onPressed: _toggleSave,
              ),
            ),
            const SizedBox(width: 10),

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
                  minimumSize: const Size.fromHeight(48),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Apply Now',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 16),
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
