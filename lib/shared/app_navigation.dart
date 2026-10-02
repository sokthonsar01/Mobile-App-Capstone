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

  final bool isMovingRight = targetIndex > currentIndex;

  if (currentIndex == 0) {
    Navigator.push(
      context,
      createDirectionalPageRoute(
        page: targetScreen,
        isMovingRight: isMovingRight,
      ),
    );
  } else {
    Navigator.pushReplacement(
      context,
      createDirectionalPageRoute(
        page: targetScreen,
        isMovingRight: isMovingRight,
      ),
    );
  }
}
