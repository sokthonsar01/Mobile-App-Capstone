import 'package:flutter/material.dart';
// ===== TEMP FOR TESTING - REMOVE BEFORE COMMITTING =====
// import 'features/splash/presentation/splash_screen.dart';
import 'dev_menu_screen.dart';

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
      theme: ThemeData(useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}
