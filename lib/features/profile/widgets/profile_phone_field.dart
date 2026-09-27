import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';

/// Phone number input with country code dropdown selector.
class ProfilePhoneField extends StatelessWidget {
  final String countryCode;
  final TextEditingController controller;
  final ValueChanged<String?> onCountryCodeChanged;

  const ProfilePhoneField({
    super.key,
    required this.countryCode,
    required this.controller,
    required this.onCountryCodeChanged,
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.isDark ? [] : softShadow,
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
                              color: AppColors.heading,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onCountryCodeChanged,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: AppColors.heading,
                  ),
                ),
              ),
              Container(width: 1, height: 26, color: AppColors.cardBorder),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: AppColors.heading,
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
