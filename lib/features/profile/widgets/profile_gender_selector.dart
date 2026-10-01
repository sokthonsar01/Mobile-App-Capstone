import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';

/// Gender selector row for the profile form.
class ProfileGenderSelector extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const ProfileGenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.heading,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildOption('Male')),
            const SizedBox(width: 16),
            Expanded(child: _buildOption('Female')),
          ],
        ),
      ],
    );
  }

  Widget _buildOption(String value) {
    final bool isSelected = selectedGender == value;

    return GestureDetector(
      onTap: enabled ? () => onChanged(value) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: !enabled
              ? (AppColors.isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFF1F5F9))
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: enabled && !AppColors.isDark ? softShadow : null,
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.heading.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.heading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
