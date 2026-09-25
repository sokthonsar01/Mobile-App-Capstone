import 'package:flutter/material.dart';

import '../../../shared/app_colors.dart';
import '../presentation/update_password_screen.dart';
import 'logout_sheet.dart';

/// Shows the bottom sheet modal with profile settings options (update password, log out).
void showProfileSettingsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Update password'),
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
              title: const Text('Log out'),
              onTap: () {
                Navigator.pop(sheetContext);
                showLogoutSheet(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
