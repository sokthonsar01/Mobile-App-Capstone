import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';

/// Bottom sheet for filtering internships by category, location, and payment.
class FilterBottomSheet extends StatefulWidget {
  final String selectedCategory;
  final String? selectedLocation;
  final bool paymentOnly;
  final Function(String category, String? location, bool paymentOnly) onApply;

  const FilterBottomSheet({
    super.key,
    required this.selectedCategory,
    this.selectedLocation,
    this.paymentOnly = false,
    required this.onApply,
  });

  static void show(
    BuildContext context, {
    required String selectedCategory,
    String? selectedLocation,
    bool paymentOnly = false,
    required Function(String category, String? location, bool paymentOnly)
        onApply,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return FilterBottomSheet(
          selectedCategory: selectedCategory,
          selectedLocation: selectedLocation,
          paymentOnly: paymentOnly,
          onApply: onApply,
        );
      },
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _category = widget.selectedCategory;
  late String? _location = widget.selectedLocation;
  late bool _paymentOnly = widget.paymentOnly;

  final List<String> _categories = [
    'All',
    'Tech',
    'Marketing',
    'Design',
    'Finance',
  ];

  final List<String> _locations = [
    'All Locations',
    'Khan Sen Sok, Phnom Penh',
    'Khan Toul Kork, Phnom Penh',
    'Chamkar Mon, Phnom Penh',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Internships',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _category = 'All';
                      _location = null;
                      _paymentOnly = false;
                    });
                  },
                  child: Text(
                    'Reset',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category Section
            Text(
              'Category',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final bool isSelected = _category == cat;
                return ChoiceChip(
                  label: Text(
                    cat,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.heading,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primaryBlue,
                  backgroundColor: AppColors.lightFill,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : Colors.transparent,
                    ),
                  ),
                  onSelected: (bool selected) {
                    setState(() => _category = cat);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Location Section
            Text(
              'Location',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.lightFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _location ?? 'All Locations',
                  items: _locations.map((loc) {
                    return DropdownMenuItem<String>(
                      value: loc,
                      child: Text(
                        loc,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.heading,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _location = val == 'All Locations' ? null : val;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paid internships only',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading,
                  ),
                ),
                Switch.adaptive(
                  value: _paymentOnly,
                  activeTrackColor: AppColors.primaryBlue,
                  onChanged: (bool val) {
                    setState(() => _paymentOnly = val);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Apply Button
            WideButton(
              text: 'APPLY FILTERS',
              onPressed: () {
                Navigator.pop(context);
                widget.onApply(_category, _location, _paymentOnly);
              },
            ),
          ],
        ),
      ),
    );
  }
}
