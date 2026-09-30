import 'package:flutter/material.dart';

/// Central controller managing the app's ThemeMode (Light, Dark, System Auto).
class AppThemeController {
  AppThemeController._();
  static final AppThemeController instance = AppThemeController._();

  /// Reactive notifier for the active ThemeMode.
  final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

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
    if (themeModeNotifier.value == mode) return;
    themeModeNotifier.value = mode;
    _rebuildAllWidgets();
  }

  /// Most screens read colors from the static [AppColors] getters, which do
  /// not tell Flutter when they change. Without this, screens that are not
  /// listening to [themeModeNotifier] keep their old text colors after a
  /// toggle (e.g. dark text left on the new dark background).
  /// Marking every element dirty makes all screens redraw with the new palette.
  void _rebuildAllWidgets() {
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(rebuild);
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
