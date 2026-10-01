import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../page_transitions.dart';

/// Professional Light and Dark theme configurations for the Interna app.
class AppThemes {
  AppThemes._();

  // ---------------------------------------------------------------------------
  // 1. Light Theme
  // ---------------------------------------------------------------------------
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    primaryColor: AppColors.primaryBlue,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryBlue,
      secondary: Color(0xFF2563EB),
      surface: Colors.white,
      onSurface: Color(0xFF0D0141),
      error: AppColors.danger,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF0D0141),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF0D0141),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SmoothFadeSlidePageTransitionsBuilder(),
        TargetPlatform.iOS: SmoothFadeSlidePageTransitionsBuilder(),
        TargetPlatform.macOS: SmoothFadeSlidePageTransitionsBuilder(),
        TargetPlatform.linux: SmoothFadeSlidePageTransitionsBuilder(),
        TargetPlatform.windows: SmoothFadeSlidePageTransitionsBuilder(),
      },
    ),
  );

  // ---------------------------------------------------------------------------
  // 2. Dark Theme
  // ---------------------------------------------------------------------------
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
    primaryColor: AppColors.primaryBlue,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryBlue,
      secondary: Color(0xFF60A5FA),
      surface: Color(0xFF1E293B), // Slate 800
      onSurface: Color(0xFFF8FAFC), // Slate 50
      error: Color(0xFFEF4444),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E293B),
      foregroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: const Color(0xFFF8FAFC),
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E293B),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF334155)),
      ),
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SmoothFadeSlidePageTransitionsBuilder(),
        TargetPlatform.iOS: SmoothFadeSlidePageTransitionsBuilder(),
        TargetPlatform.macOS: SmoothFadeSlidePageTransitionsBuilder(),
        TargetPlatform.linux: SmoothFadeSlidePageTransitionsBuilder(),
        TargetPlatform.windows: SmoothFadeSlidePageTransitionsBuilder(),
      },
    ),
  );
}
