import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/app_colors.dart';
import 'auth_navigation.dart';

/// Guest mode.
///
/// A guest is simply a person with no Supabase session. There is no guest
/// account, no guest row in the database, and no guest flag to keep in sync.
/// We ask Supabase every time, so there is only ONE source of truth.
///
/// A guest may browse the public screens. Anything that belongs to a person
/// (apply, save, messages, notifications, profile) must call requireLogin
/// first.

/// true when nobody is logged in.
bool get isGuest => Supabase.instance.client.auth.currentSession == null;

/// The gate. Put this on the first line of any action a guest may not do.
///
/// ```dart
/// void _handleApply() {
///   if (!requireLogin(context, action: 'apply for an internship')) return;
///   // ... the real apply code runs only for a logged in user
/// }
/// ```
///
/// Returns true when the user is logged in, so the action continues.
/// Returns false for a guest, and shows the sheet that invites them to log in.
bool requireLogin(BuildContext context, {String action = 'do this'}) {
  if (!isGuest) return true;

  showLoginRequiredSheet(context, action: action);
  return false;
}

/// The bottom sheet a guest sees when they tap something they cannot use.
///
/// `action` finishes the sentence "You need an account to ...", so pass a
/// short verb phrase like 'save this internship'.
void showLoginRequiredSheet(
  BuildContext context, {
  String action = 'do this',
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The small gray line at the top of the sheet.
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Login required',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You need an account to $action. It takes less than a minute.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                height: 1.5,
                color: AppColors.bodyText,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Close the sheet first, then leave the browsing screens.
                  Navigator.pop(sheetContext);
                  // backToLogin already clears the whole stack, so after the
                  // user logs in they land on one clean home screen instead
                  // of a home screen sitting on top of the guest one.
                  backToLogin(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'LOGIN',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(sheetContext),
              child: Text(
                'Keep looking around',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bodyText,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
