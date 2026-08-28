import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/internship_model.dart';
import 'application_details_screen.dart';
import 'home_screen.dart';

/// Full-screen Success view displayed after submitting an internship application.
class ApplicationSubmittedScreen extends StatelessWidget {
  final InternshipOpportunity? internship;

  const ApplicationSubmittedScreen({
    super.key,
    this.internship,
  });

  @override
  Widget build(BuildContext context) {
    final item = internship ?? demoInternships.firstWhere(
      (e) => e.id == 'hanuman-06',
      orElse: () => demoInternships.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF2B59FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),

              // 1. Success Circle Checkmark Icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 2. Main Title
              Text(
                'Application submitted',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 10),

              // 3. Subtitle
              Text(
                'You will be notified if you are shortlisted.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),

              const Spacer(),

              // 4. Action Buttons at Bottom
              // "Back to Home" Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2B59FF),
                  minimumSize: const Size.fromHeight(52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // "View Application" Button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApplicationDetailsScreen(
                        internship: item,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(
                  'View Application',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
