import 'package:flutter/material.dart';

import 'theme/app_theme_controller.dart';

/// Every color the app uses, in one place.
/// Dynamically adapts to Light Mode and Dark Mode in real time.
class AppColors {
  AppColors._();

  static bool get isDark => AppThemeController.instance.isDark;

  // --- Brand ---------------------------------------------------------------

  /// Main blue. Buttons, links, selected icons.
  static const Color primaryBlue = Color(0xFF3B66FF);

  /// Lighter blue used at the top of the profile header gradient.
  static const Color headerBlueLight = Color(0xFF4A7BFF);

  /// Darker blue used at the bottom of the profile header gradient.
  static const Color headerBlueDark = Color(0xFF1E5CFB);

  // --- Text (Dynamic for Dark/Light Mode) -----------------------------------

  /// Page titles and field labels.
  static Color get heading =>
      isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0D0141);

  /// Normal paragraph text.
  static Color get bodyText =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF524B6C);

  /// Placeholder text inside an empty field, and small gray times.
  static Color get hintText =>
      isDark ? const Color(0xFF64748B) : const Color(0xFF6D678B);

  // --- Surfaces (Dynamic for Dark/Light Mode) --------------------------------

  /// Page background color.
  static Color get background =>
      isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

  /// Card, sheet, and modal surface color.
  static Color get surface =>
      isDark ? const Color(0xFF1E293B) : Colors.white;

  /// Card border outline color.
  static Color get cardBorder =>
      isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  /// Thin line around text fields.
  static Color get border =>
      isDark ? const Color(0xFF475569) : const Color(0xFFC6C6C6);

  /// Gray fill: search bar, chips.
  static Color get lightFill =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFF4F4F4);

  /// Pale blue background of an unread notification row.
  static Color get unreadBlue => isDark
      ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
      : const Color(0xFFEBF0FF);

  /// Bubble for the other person's chat message.
  static Color get otherBubble =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFE7ECFF);

  // --- Status --------------------------------------------------------------

  /// Red for the CANCEL button and the delete icon.
  static const Color danger = Color(0xFFDC2626);

  /// Green dot for "Online" and the double check mark.
  static const Color online = Color(0xFF2E9E4F);
}
