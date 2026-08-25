import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../auth/auth_navigation.dart';

/// Shows the "Log out" panel that slides up from the bottom.
///
/// This is a function, not a widget class, because we only ever call it.
/// Use it like this:  showLogoutSheet(context);
void showLogoutSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            // min means: only be as tall as the content inside.
            mainAxisSize: MainAxisSize.min,
            children: [
              // The small dark bar at the top that you can drag.
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.heading,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Log out',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to leave?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.bodyText,
                ),
              ),
              const SizedBox(height: 24),
              WideButton(
                text: 'YES',
                onPressed: () {
                  // Close the panel first, then go back to login.
                  Navigator.pop(sheetContext);
                  backToLogin(context);
                },
              ),
              const SizedBox(height: 12),
              WideButton(
                text: 'CANCEL',
                color: AppColors.danger,
                onPressed: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        ),
      );
    },
  );
}
