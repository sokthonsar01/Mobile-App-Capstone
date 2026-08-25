import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth_colors.dart';
import 'login_screen.dart';

/// First screen the user sees: the app name, a picture, a big sentence
/// and a round blue arrow button that opens the login screen.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App name in the top right corner.
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Interna',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),

              // Expanded means: take all the free space that is left.
              // We use it so the picture shrinks on small phones
              // instead of causing an overflow error.
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/illustration_intern.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // RichText lets us put two colors inside one sentence.
              RichText(
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: Colors.black,
                  ),
                  children: const [
                    TextSpan(text: 'Where\nTalent Meets\n'),
                    TextSpan(
                      text: 'Opportunity!',
                      style: TextStyle(color: AuthColors.primaryBlue),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Explore all the most exciting job roles based '
                'on your interest and study major.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  height: 1.6,
                  color: AuthColors.bodyText,
                ),
              ),

              const SizedBox(height: 32),

              // Round blue arrow button on the right side.
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AuthColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
