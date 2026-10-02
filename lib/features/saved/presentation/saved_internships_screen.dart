import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/app_navigation.dart';
import '../../../shared/theme/app_theme_controller.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../home/data/internship_model.dart';
import '../../home/presentation/internship_details_screen.dart';
import '../../home/widgets/company_logo_widget.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../viewmodel/saved_internships_viewmodel.dart';

/// The Saved Internships screen displaying all bookmarked opportunities in real-time.
/// Synchronized via SavedInternshipsViewModel (MVVM) with NestJS backend.
class SavedInternshipsScreen extends StatefulWidget {
  const SavedInternshipsScreen({super.key});

  @override
  State<SavedInternshipsScreen> createState() => _SavedInternshipsScreenState();
}

class _SavedInternshipsScreenState extends State<SavedInternshipsScreen> {
  final SavedInternshipsViewModel _viewModel = SavedInternshipsViewModel.instance;

  @override
  void initState() {
    super.initState();
    _viewModel.loadSavedInternships();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final isLoading = _viewModel.isLoading;
        final savedList = _viewModel.savedInternships;

        return ValueListenableBuilder<ThemeMode>(
          valueListenable: AppThemeController.instance.themeModeNotifier,
          builder: (context, currentMode, _) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.surface,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Saved Internships',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.heading,
                      ),
                    ),
                    if (savedList.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${savedList.length}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                centerTitle: true,
                actions: [
                  if (savedList.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_sweep_outlined,
                        color: AppColors.danger,
                        size: 22,
                      ),
                      tooltip: 'Clear All Bookmarks',
                      onPressed: _confirmClearAll,
                    ),
                  const SizedBox(width: 4),
                ],
              ),
              body: isLoading && !_viewModel.hasLoadedOnce
                  ? _buildSkeletonList()
                  : RefreshIndicator(
                      color: AppColors.primaryBlue,
                      onRefresh: () =>
                          _viewModel.loadSavedInternships(force: true),
                      child: savedList.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  child: _buildEmptyState(),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 24),
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              itemCount: savedList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return _buildSavedCard(savedList[index]);
                              },
                            ),
                    ),
              bottomNavigationBar: AppBottomNav(
                currentIndex: 1,
                onTap: (int index) => navigateToAppTab(context, 1, index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSkeleton(width: 48, height: 48, borderRadius: 12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        AppSkeleton(width: 170, height: 16, borderRadius: 4),
                        SizedBox(height: 8),
                        AppSkeleton(width: 110, height: 13, borderRadius: 4),
                      ],
                    ),
                  ),
                  const AppSkeleton.circular(size: 24),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: const [
                  AppSkeleton(width: 64, height: 22, borderRadius: 6),
                  SizedBox(width: 8),
                  AppSkeleton(width: 72, height: 22, borderRadius: 6),
                  SizedBox(width: 8),
                  AppSkeleton(width: 58, height: 22, borderRadius: 6),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  AppSkeleton(width: 100, height: 14, borderRadius: 4),
                  AppSkeleton(width: 88, height: 32, borderRadius: 10),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  /// Empty state when no internships are saved
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFDBEAFE),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.bookmark_outline_rounded,
                size: 38,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Saved Internships Yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore opportunities on the Home screen and tap the bookmark icon to save them for quick access here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: AppColors.bodyText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => navigateToAppTab(context, 1, 0),
              icon: const Icon(Icons.search_rounded, size: 18),
              label: Text(
                'Explore Internships',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card displaying a saved internship opportunity
  Widget _buildSavedCard(InternshipOpportunity item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  internship: item,
                  initialSaved: true,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Logo + Title + Bookmark Delete Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CompanyLogoWidget(
                      logoKey: item.logoKey,
                      companyName: item.company,
                      brandColor: item.brandColor,
                      size: 46,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.role,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.heading,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.company,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
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
                                size: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.bookmark_rounded,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                      tooltip: 'Remove from Saved',
                      onPressed: () => _removeOne(item),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Tags Row
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildPillTag(
                      text: item.category,
                      color: AppColors.primaryBlue,
                      bgColor: const Color(0xFFEFF6FF),
                    ),
                    _buildPillTag(
                      text: item.stipend.contains('/')
                          ? item.stipend.split('/').first.trim()
                          : item.stipend,
                      color: const Color(0xFF059669),
                      bgColor: const Color(0xFFECFDF5),
                    ),
                    _buildPillTag(
                      text: item.schedule.split(':').first.trim(),
                      color: const Color(0xFF475569),
                      bgColor: const Color(0xFFF1F5F9),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bottom details row
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.hintText,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.location,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: AppColors.hintText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Closes ${item.deadline}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFDC2626),
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

  Widget _buildPillTag({
    required String text,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _removeOne(InternshipOpportunity item) {
    _viewModel.remove(item.id);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Removed "${item.role}" from saved',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: const Color(0xFF60A5FA),
          onPressed: () {
            _viewModel.save(item);
          },
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _confirmClearAll() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Clear All Saved?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          content: Text(
            'Are you sure you want to remove all saved internship bookmarks?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: AppColors.bodyText,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: AppColors.bodyText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _viewModel.clearAll();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Clear All',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
