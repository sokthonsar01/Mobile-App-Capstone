import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/home/data/internship_model.dart';
import 'package:interna/features/home/presentation/application_details_screen.dart';
import 'package:interna/features/home/presentation/application_submitted_screen.dart';
import 'package:interna/features/home/presentation/company_profile_screen.dart';
import 'package:interna/features/home/presentation/create_post_screen.dart';
import 'package:interna/features/home/presentation/home_screen.dart';
import 'package:interna/features/home/presentation/offline_error_screen.dart';
import 'package:interna/features/home/widgets/company_logo_widget.dart';
import 'package:interna/features/home/widgets/internship_card.dart';
import 'package:interna/features/profile/presentation/edit_profile_screen.dart';

void main() {
  testWidgets('HomeScreen works, posters auto-rotate every 5s, and logos/posters match internships', (WidgetTester tester) async {
    // 1. Pump HomeScreen widget
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pump();

    // 2. Verify HomeScreen UI elements load correctly
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Max Verstappen'), findsOneWidget);
    expect(find.text('Search internships...'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);

    // 3. Verify internship cards and company logos/posters match
    expect(find.byType(InternshipCard), findsWidgets);
    expect(find.byType(CompanyLogoWidget), findsWidgets);

    // Verify asset paths on model matching logos and posters
    for (final item in demoInternships) {
      expect(item.logoAssetPath, contains('assets/images/logos/'));
      expect(item.posterAssetPath, contains('assets/images/posters/'));
      expect(item.bannerPosterAssetPath, contains('assets/images/posters/'));
    }

    // 4. Verify 5-second auto-rotation of top wide banner
    final pageViewFinder = find.byType(PageView);
    expect(pageViewFinder, findsOneWidget);

    final pageViewBefore = tester.widget<PageView>(pageViewFinder);
    final initialPage = pageViewBefore.controller?.page?.round() ?? 0;

    // Pump 5 seconds for timer to fire
    await tester.pump(const Duration(seconds: 5));
    // Pump animation frame
    await tester.pump(const Duration(milliseconds: 700));

    final pageViewAfter = tester.widget<PageView>(pageViewFinder);
    final pageAfter = pageViewAfter.controller?.page?.round() ?? 0;

    expect(pageAfter, equals(initialPage + 1));
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
  });
}
