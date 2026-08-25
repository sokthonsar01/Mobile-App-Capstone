import 'package:flutter/material.dart';

/// Every color the app uses, in one place.
///
/// Change a color here and it changes on every screen.
class AppColors {
  AppColors._();

  // --- Brand ---------------------------------------------------------------

  /// Main blue. Buttons, links, selected icons.
  static const Color primaryBlue = Color(0xFF3B66FF);

  /// Lighter blue used at the top of the profile header gradient.
  static const Color headerBlueLight = Color(0xFF4A7BFF);

  /// Darker blue used at the bottom of the profile header gradient.
  static const Color headerBlueDark = Color(0xFF1E5CFB);

  // --- Text ----------------------------------------------------------------

  /// Page titles and field labels.
  static const Color heading = Color(0xFF0D0141);

  /// Normal paragraph text.
  static const Color bodyText = Color(0xFF524B6C);

  /// Placeholder text inside an empty field, and small gray times.
  static const Color hintText = Color(0xFF6D678B);

  // --- Surfaces ------------------------------------------------------------

  /// Thin gray line around the auth text fields.
  static const Color border = Color(0xFFC6C6C6);

  /// Light gray fill: search bar, chips.
  static const Color lightFill = Color(0xFFF4F4F4);

  /// Pale blue background of an unread notification row.
  static const Color unreadBlue = Color(0xFFEBF0FF);

  /// Light blue bubble for the other person's chat message.
  static const Color otherBubble = Color(0xFFE7ECFF);

  // --- Status --------------------------------------------------------------

  /// Red for the CANCEL button and the delete icon.
  static const Color danger = Color(0xFFDC2626);

  /// Green dot for "Online" and the double check mark.
  static const Color online = Color(0xFF2E9E4F);
}
