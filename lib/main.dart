import 'package:flutter/material.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'shared/page_transitions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interna',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: SmoothFadeSlidePageTransitionsBuilder(),
            TargetPlatform.iOS: SmoothFadeSlidePageTransitionsBuilder(),
            TargetPlatform.macOS: SmoothFadeSlidePageTransitionsBuilder(),
            TargetPlatform.linux: SmoothFadeSlidePageTransitionsBuilder(),
            TargetPlatform.windows: SmoothFadeSlidePageTransitionsBuilder(),
          },
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
