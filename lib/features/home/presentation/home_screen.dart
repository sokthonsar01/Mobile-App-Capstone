import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../messages/presentation/messages_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../profile/presentation/edit_profile_screen.dart';
import '../data/internship_model.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/internship_card.dart';
import 'application_details_screen.dart';
import 'create_post_screen.dart';

/// The main Home / Internship Explorer Dashboard screen.
/// Supports both online and offline (Error State) modes.
class HomeScreen extends StatefulWidget {
  final bool isOffline;

  const HomeScreen({
    super.key,
    this.isOffline = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  late bool _isOffline;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

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
  void initState() {
    super.initState();
    _isOffline = widget.isOffline;

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _shimmerAnimation = Tween<double>(begin: 0.45, end: 0.9).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );

    if (_isOffline) {
      _shimmerController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _shimmerController.dispose();
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
          !item.location.toLowerCase().contains(
            _selectedLocation!.toLowerCase(),
          )) {
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
      return;
    } else if (index == 1) {
      _openFilters();
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ApplicationDetailsScreen(),
        ),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MessagesScreen()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
      );
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
            // Top App Bar: Profile or "No connection" Red Banner
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

            // Suggestions List or Skeleton Loading when Offline
            if (_isOffline)
              _buildSkeletonList()
            else if (items.isEmpty)
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

  /// Top Bar: Profile avatar on left (Online) OR Centered "No connection" Pill (Offline).
  Widget _buildTopHeader() {
    if (_isOffline) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 44),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isOffline = !_isOffline;
                      if (_isOffline) {
                        _shimmerController.repeat(reverse: true);
                      } else {
                        _shimmerController.stop();
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD92D20),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD92D20).withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'No connection',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Please check your connection!',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.95),
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Greeting Text & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good afternoon, Max 👋',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Find internships that fit you.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.hintText,
                  ),
                ),
              ],
            ),
          ),

          // Notification Bell in styled round card
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.heading,
                    size: 22,
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
          // Row with "Internship Explorer" and "Filters" Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Internship Explorer',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
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
                  color: isSelected
                      ? AppColors.primaryBlue
                      : Colors.transparent,
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

  /// Skeleton Loading Placeholders for Error/Offline state.
  Widget _buildSkeletonList() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(3, (index) {
              return Container(
                width: double.infinity,
                height: 146,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBEBEB).withValues(
                    alpha: _shimmerAnimation.value,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
