import 'package:flutter/material.dart';

import '../features/applications/presentation/application_tracker_screen.dart';
import '../features/chat/presentation/messages_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/saved/presentation/saved_internships_screen.dart';
import 'page_transitions.dart';

/// Centralized navigation helper for the 5 core bottom tabs in the Internship app:
/// 0 = Home (Internship explorer & search)
/// 1 = Saved (Bookmarked internships)
/// 2 = Applications (Application status tracker)
/// 3 = Messages (Recruiter & company chats)
/// 4 = Profile (Student profile & settings)
void navigateToAppTab(BuildContext context, int currentIndex, int targetIndex) {
  if (currentIndex == targetIndex) return;

  if (targetIndex == 0) {
    // Pop back to the root HomeScreen without pushing new route instances
    Navigator.popUntil(context, (route) => route.isFirst);
    return;
  }

  Widget targetScreen;
  switch (targetIndex) {
    case 1:
      targetScreen = const SavedInternshipsScreen();
      break;
    case 2:
      targetScreen = const ApplicationTrackerScreen();
      break;
    case 3:
      targetScreen = const MessagesScreen();
      break;
    case 4:
      targetScreen = const EditProfileScreen();
      break;
    default:
      return;
  }

  if (currentIndex == 0) {
    Navigator.push(
      context,
      createSmoothPageRoute(page: targetScreen),
    );
  } else {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }
}
