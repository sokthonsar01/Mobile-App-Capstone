import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/home/data/internship_model.dart';
import 'package:interna/features/home/presentation/application_details_screen.dart';
import 'package:interna/features/home/presentation/application_submitted_screen.dart';
import 'package:interna/features/home/presentation/company_profile_screen.dart';
import 'package:interna/features/home/presentation/create_post_screen.dart';
import 'package:interna/features/home/presentation/home_screen.dart';
import 'package:interna/features/home/presentation/offline_error_screen.dart';
import 'package:interna/features/profile/presentation/edit_profile_screen.dart';

void main() {
  testWidgets('HomeScreen full smoke and interaction test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // 1. Check Header & Top Banner
    expect(find.text('Good afternoon, Max 👋'), findsOneWidget);
    expect(find.text('Find internships that fit you.'), findsOneWidget);
    expect(find.text('Internship Explorer'), findsOneWidget);
    expect(find.text('Suggestions'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Tech'), findsOneWidget);
    expect(find.text('Marketing'), findsOneWidget);
    expect(find.text('Design'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);

    // 2. Check default card items rendered
    expect(find.text('Marketing Intern at Chip Mong'), findsOneWidget);
    expect(find.text('Finance Intern at Canadia Bank'), findsOneWidget);

    // 3. Test Search Box Live Filtering
    await tester.enterText(find.byType(TextField), 'Cellcard');
    await tester.pump();

    expect(find.text('AI Specialist Intern at Cellcard'), findsOneWidget);
    expect(find.text('Marketing Intern at Chip Mong'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear_rounded));
    await tester.pump();

    // 4. Test Category Filter
    await tester.tap(find.text('Design'));
    await tester.pump();

    expect(find.text('UX/UI Intern at Smart'), findsOneWidget);
    expect(find.text('Finance Intern at Canadia Bank'), findsNothing);

    // Switch back to All
    await tester.tap(find.text('All'));
    await tester.pump();

    expect(find.text('Marketing Intern at Chip Mong'), findsOneWidget);

    // 5. Test "View Details" navigates to Internship Details Screen
    await tester.tap(find.text('View Details').first);
    await tester.pumpAndSettle();

    expect(find.text('Matching Percentage: 90%'), findsOneWidget);
    expect(find.text('Internship Information'), findsOneWidget);
    expect(find.text('Apply Now'), findsOneWidget);
  });

  testWidgets('OfflineErrorScreen renders No Connection banner and suggestions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OfflineErrorScreen(),
      ),
    );

    await tester.pump();

    expect(find.text('No connection'), findsOneWidget);
    expect(find.text('Please check your connection!'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    expect(find.text('Welcome back, Max!'), findsOneWidget);
    expect(find.text('Internship Explorer'), findsOneWidget);
    expect(find.text('Suggestions'), findsOneWidget);
  });

  testWidgets('Application screens smoke test', (WidgetTester tester) async {
    final item = demoInternships.first;

    // Test Success Screen
    await tester.pumpWidget(
      MaterialApp(
        home: ApplicationSubmittedScreen(internship: item),
      ),
    );
    expect(find.text('Application submitted'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);
    expect(find.text('View Application'), findsOneWidget);

    // Test Application Details Screen
    await tester.pumpWidget(
      MaterialApp(
        home: ApplicationDetailsScreen(internship: item),
      ),
    );
    expect(find.text('Application Details'), findsOneWidget);
    expect(find.text('Current Stage: Under Review'), findsOneWidget);
    expect(find.text('Your Submission:'), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Back to Home'), 200);
    expect(find.text('Back to Home'), findsOneWidget);

    // Test Company Profile Screen
    await tester.pumpWidget(
      MaterialApp(
        home: CompanyProfileScreen(internship: item),
      ),
    );
    expect(find.text('Company Profile'), findsOneWidget);

    // Test Create Post Screen
    await tester.pumpWidget(
      const MaterialApp(
        home: CreatePostScreen(),
      ),
    );
    expect(find.text('Create Post'), findsOneWidget);
    expect(find.text('Post title'), findsOneWidget);

    // Test Edit Profile Screen
    await tester.pumpWidget(
      const MaterialApp(
        home: EditProfileScreen(),
      ),
    );
    expect(find.text('Max Verstappen'), findsWidgets);
    expect(find.text('Fullname'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
  });
}
