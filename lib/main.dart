import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_env.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'shared/theme/app_theme_controller.dart';
import 'shared/theme/app_themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    publishableKey: AppEnv.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.instance.themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: AppEnv.appName,
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
