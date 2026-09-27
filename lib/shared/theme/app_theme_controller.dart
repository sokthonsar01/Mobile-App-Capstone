import 'package:flutter/material.dart';

/// Central controller managing the app's ThemeMode (Light, Dark, System Auto).
class AppThemeController {
  AppThemeController._();
  static final AppThemeController instance = AppThemeController._();

  /// Reactive notifier for the active ThemeMode.
  final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  ThemeMode get currentThemeMode => themeModeNotifier.value;

  bool get isDark {
    if (themeModeNotifier.value == ThemeMode.dark) return true;
    if (themeModeNotifier.value == ThemeMode.light) return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  void toggleTheme() {
    if (isDark) {
      setLightMode();
    } else {
      setDarkMode();
    }
  }

  void setThemeMode(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }

  void setLightMode() => setThemeMode(ThemeMode.light);
  void setDarkMode() => setThemeMode(ThemeMode.dark);
  void setSystemMode() => setThemeMode(ThemeMode.system);

  bool isDarkMode(BuildContext context) {
    if (themeModeNotifier.value == ThemeMode.dark) return true;
    if (themeModeNotifier.value == ThemeMode.light) return false;
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }
}
