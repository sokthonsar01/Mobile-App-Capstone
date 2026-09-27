import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/theme/app_theme_controller.dart';
import '../presentation/update_password_screen.dart';
import 'logout_sheet.dart';

/// Shows the bottom sheet modal with profile settings options (update password, theme toggle, log out).
void showProfileSettingsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return ValueListenableBuilder<ThemeMode>(
        valueListenable: AppThemeController.instance.themeModeNotifier,
        builder: (context, currentMode, _) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    AppColors.isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    color: AppColors.primaryBlue,
                  ),
                  title: Text(
                    AppColors.isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: AppColors.heading,
                    ),
                  ),
                  trailing: Switch.adaptive(
                    value: AppColors.isDark,
                    activeThumbColor: AppColors.primaryBlue,
                    onChanged: (bool val) {
                      AppThemeController.instance.toggleTheme();
                    },
                  ),
                  onTap: () {
                    AppThemeController.instance.toggleTheme();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.lock_outline, color: AppColors.heading),
                  title: Text(
                    'Update password',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: AppColors.heading,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UpdatePasswordScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.danger),
                  title: Text(
                    'Log out',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showLogoutSheet(context);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      );
    },
  );
}

