import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';

/// Phone number input with country code dropdown selector.
class ProfilePhoneField extends StatelessWidget {
  final String countryCode;
  final TextEditingController controller;
  final ValueChanged<String?> onCountryCodeChanged;
  final bool enabled;

  const ProfilePhoneField({
    super.key,
    required this.countryCode,
    required this.controller,
    required this.onCountryCodeChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone number',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.heading,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: !enabled
                ? (AppColors.isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF1F5F9))
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: !enabled
                  ? AppColors.cardBorder.withValues(alpha: 0.6)
                  : AppColors.cardBorder,
            ),
            boxShadow: enabled && !AppColors.isDark ? softShadow : null,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: DropdownButton<String>(
                  value: countryCode,
                  dropdownColor: AppColors.surface,
                  underline: const SizedBox.shrink(),
                  items: const ['+855', '+66', '+84', '+1']
                      .map(
                        (code) => DropdownMenuItem<String>(
                          value: code,
                          child: Text(
                            code,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              color: !enabled ? AppColors.hintText : AppColors.heading,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: enabled ? onCountryCodeChanged : null,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: !enabled ? AppColors.hintText : AppColors.heading,
                  ),
                ),
              ),
              Container(width: 1, height: 26, color: AppColors.cardBorder),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: !enabled ? AppColors.hintText : AppColors.heading,
                    fontWeight: !enabled ? FontWeight.w500 : FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
