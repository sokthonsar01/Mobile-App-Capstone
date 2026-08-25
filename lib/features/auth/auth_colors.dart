import 'package:flutter/material.dart';

import '../../shared/app_colors.dart';

/// The real color values moved to `lib/shared/app_colors.dart`, because the
/// profile, messages, saved and notification screens need the same ones.
///
/// This class only forwards the old names to the new place, so the auth
/// screens keep working without any edit. There is still ONE source of
/// truth: `AppColors`.
///
/// New screens should use `AppColors` directly.
class AuthColors {
  AuthColors._();

  static const Color primaryBlue = AppColors.primaryBlue;
  static const Color heading = AppColors.heading;
  static const Color bodyText = AppColors.bodyText;
  static const Color hintText = AppColors.hintText;
  static const Color border = AppColors.border;
}
