import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../messages/presentation/messages_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../profile/presentation/edit_profile_screen.dart';
import '../../saved/presentation/saved_internships_screen.dart';
import '../data/internship_model.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/internship_card.dart';

/// The main Home / Internship Explorer Dashboard screen.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String? _selectedLocation;
  bool _paymentOnly = false;

  final Set<String> _savedIds = {'cm-01', 'cellcard-03'};

  final List<String> _categories = [
    'All',
    'Tech',
    'Marketing',
    'Design',
    'Finance',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filters the internship list by search query, category, location, and payment.
  List<InternshipOpportunity> get _filteredInternships {
    final query = _searchController.text.trim().toLowerCase();

    return demoInternships.where((item) {
      // Category filter
      if (_selectedCategory != 'All' && item.category != _selectedCategory) {
        return false;
      }

      // Location filter
      if (_selectedLocation != null &&
          !item.location.toLowerCase().contains(_selectedLocation!.toLowerCase())) {
        return false;
      }

      // Search query
      if (query.isNotEmpty) {
        final matchesRole = item.role.toLowerCase().contains(query);
        final matchesCompany = item.company.toLowerCase().contains(query);
        final matchesLocation = item.location.toLowerCase().contains(query);
        final matchesCategory = item.category.toLowerCase().contains(query);

        if (!matchesRole &&
            !matchesCompany &&
            !matchesLocation &&
            !matchesCategory) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _openFilters() {
    FilterBottomSheet.show(
      context,
      selectedCategory: _selectedCategory,
      selectedLocation: _selectedLocation,
      paymentOnly: _paymentOnly,
      onApply: (category, location, paymentOnly) {
        setState(() {
          _selectedCategory = category;
          _selectedLocation = location;
          _paymentOnly = paymentOnly;
        });
      },
    );
  }

  void _handleBottomNavTap(int index) {
    if (index == 0) {
      // Already on home, scroll to top
      return;
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MessagesScreen()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SavedInternshipsScreen()),
      );
    } else if (index == 2) {
      _openFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredInternships;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          children: [
            // Top App Bar with Profile Avatar and Notification Bell
            _buildTopHeader(),

            // Hero Blue Banner Card with Search & Filters
            _buildHeroBanner(),

            // Horizontal Category Selector Chips
            _buildCategoryChips(),

            // "Suggestions" Section Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                'Suggestions',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.heading,
                ),
              ),
            ),

            // Suggestions List or Empty State
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 48,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 56,
                        color: AppColors.hintText.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No internships found',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try searching with different keywords or clearing your filters.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.hintText,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: items.map((internship) {
                    final isSaved = _savedIds.contains(internship.id);

                    return InternshipCard(
                      internship: internship,
                      isSaved: isSaved,
                      onToggleSave: () {
                        setState(() {
                          if (isSaved) {
                            _savedIds.remove(internship.id);
                          } else {
                            _savedIds.add(internship.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  /// Top Bar: Profile avatar on left + Notification bell on right.
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Avatar
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const InitialsAvatar(
                name: 'Max Verstappen',
                size: 40,
              ),
            ),
          ),

          // Notification Bell with unread dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.heading,
                  size: 28,
                ),
              ),
              Positioned(
                right: 12,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Hero Blue Card containing greeting, subtitle, filter button, and search input.
  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Row with "Filters" Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, Max!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Internship Explorer',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Filters Pill Button
              GestureDetector(
                onTap: _openFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Filters',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Discover amazing internship opportunities from top companies in Cambodia!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.35,
            ),
          ),

          const SizedBox(height: 14),

          // Search Field
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {}),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: AppColors.heading,
              ),
              decoration: InputDecoration(
                hintText: 'Search for internships...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.hintText,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.hintText,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.hintText,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Category Selection Bar (All, Tech, Marketing, Design, Finance).
  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = category);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.heading,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
