import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/home/presentation/application_details_screen.dart';
import 'package:interna/features/home/presentation/home_screen.dart';
import 'package:interna/features/profile/presentation/edit_profile_screen.dart';

void main() {
  testWidgets('Navbar links test: Tracker -> Tracker page, Profile -> Profile page, Filter -> Filter page', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pump();

    // 1. Test Filter link (Explore/Filter link at index 1 opens FilterBottomSheet)
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(find.text('Filter Internships'), findsOneWidget);

    // Close filter sheet by tapping Reset or Apply
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    // Tap outside/back to close sheet
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // 2. Test Tracker link (Tracker at index 2 -> ApplicationDetailsScreen)
    await tester.tap(find.text('Tracker'));
    await tester.pumpAndSettle();
    expect(find.byType(ApplicationDetailsScreen), findsOneWidget);
    expect(find.text('Application Details'), findsOneWidget);

    // Return to HomeScreen
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();

    // 3. Test Profile link (Profile at index 4 -> EditProfileScreen)
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(find.text('Fullname'), findsOneWidget);
  });
}
