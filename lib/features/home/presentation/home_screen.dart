import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../messages/presentation/messages_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../profile/presentation/edit_profile_screen.dart';
import '../../saved/presentation/saved_internships_screen.dart';
import '../data/internship_model.dart';
import '../widgets/company_logo_widget.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/internship_card.dart';
import '../widgets/internship_details_sheet.dart';

/// The main Home / Internship Explorer Dashboard screen.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final PageController _bannerPageController;
  Timer? _bannerTimer;

  String _selectedCategory = 'All';
  String? _selectedLocation;
  bool _paymentOnly = false;

  final Set<String> _savedIds = {'cm-01', 'cellcard-03'};

  final List<String> _categories = [
    'All',
    'IT',
    'Design',
    'Business',
    'Finance',
  ];

  @override
  void initState() {
    super.initState();
    final initialPage = demoInternships.isNotEmpty
        ? 1000 * demoInternships.length
        : 0;
    _bannerPageController = PageController(initialPage: initialPage);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || demoInternships.isEmpty) return;
      if (_bannerPageController.hasClients) {
        final currentPos = _bannerPageController.page?.round() ?? 0;
        _bannerPageController.animateToPage(
          currentPos + 1,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Filters the internship list by search query, category, location, and payment.
  List<InternshipOpportunity> get _filteredInternships {
    final query = _searchController.text.trim().toLowerCase();

    return demoInternships.where((item) {
      // Category filter
      if (_selectedCategory != 'All') {
        if (_selectedCategory == 'IT' &&
            item.category != 'Tech' &&
            item.category != 'IT') {
          return false;
        } else if (_selectedCategory == 'Business' &&
            item.category != 'Marketing' &&
            item.category != 'Business') {
          return false;
        } else if (_selectedCategory != 'IT' &&
            _selectedCategory != 'Business' &&
            item.category != _selectedCategory) {
          return false;
        }
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // 1. Top Header: Profile Icon (left) + Notification Bell (right)
            _buildTopHeader(),

            const SizedBox(height: 16),

            // 2. Featured Promotional Hero Banner Carousel (Visually matching listing cards)
            _buildPromoBanner(),

            const SizedBox(height: 16),

            // 3. Search Bar with magnifying glass on the right
            _buildSearchBar(),

            const SizedBox(height: 16),

            // 4. Horizontal Category Chips Row with Filter Icon Button
            _buildCategoryChips(),

            const SizedBox(height: 16),

            // 5. Suggestions Feed List or Empty State
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
              Column(
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
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  /// Top Bar: Profile avatar with Hello & Name on left + Notification bell on right.
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Profile Icon Button + Hello, User Name
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.heading,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hello',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.bodyText,
                    ),
                  ),
                  Text(
                    'Max Verstappen',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.heading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Notification Bell with unread dot
        Stack(
          clipBehavior: Clip.none,
          children: [
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: AppColors.heading,
                  size: 22,
                ),
              ),
            ),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Display-only wide poster banner carousel (auto-changes every 5 seconds, responsive 1280:480 aspect ratio).
  Widget _buildPromoBanner() {
    if (demoInternships.isEmpty) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: 1280 / 480,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D0141).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: PageView.builder(
            controller: _bannerPageController,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              final item = demoInternships[index % demoInternships.length];

              return Image.asset(
                item.bannerPosterAssetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: item.brandColor,
                  child: Center(
                    child: Text(
                      item.company,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Search Bar matching card rounded corners (16px) with right search icon
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D0141).withValues(alpha: 0.04),
            blurRadius: 10,
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
          hintText: 'Search internships...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.hintText,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.heading,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Category Selection Bar: Tabs fitting all labels + Blue Filter Icon Pill
  Widget _buildCategoryChips() {
    return Row(
      children: [
        // Category Chips Row
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = category);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.heading,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Filter Button Pill
        GestureDetector(
          onTap: _openFilters,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.filter_list_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

