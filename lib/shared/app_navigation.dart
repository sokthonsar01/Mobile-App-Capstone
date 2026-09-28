import 'package:flutter/material.dart';

import '../features/home/presentation/application_tracker_screen.dart';
import '../features/messages/presentation/messages_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/saved/presentation/saved_internships_screen.dart';

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
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  } else {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
