import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/home/presentation/application_tracker_screen.dart';
import 'package:interna/features/home/presentation/home_screen.dart';
import 'package:interna/features/profile/presentation/edit_profile_screen.dart';
import 'package:interna/features/saved/presentation/saved_internships_screen.dart';

void main() {
  testWidgets('Navbar links test: Saved -> Saved page, Applications -> Tracker page, Profile -> Profile page', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pump();

    // 1. Test Saved link (index 1 -> SavedInternshipsScreen)
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.byType(SavedInternshipsScreen), findsOneWidget);

    // Return to HomeScreen
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    // 2. Test Applications link (index 2 -> ApplicationTrackerScreen)
    await tester.tap(find.text('Applications'));
    await tester.pumpAndSettle();
    expect(find.byType(ApplicationTrackerScreen), findsOneWidget);

    // Return to HomeScreen
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    // 3. Test Profile link (index 4 -> EditProfileScreen)
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(EditProfileScreen), findsOneWidget);
  });
}
