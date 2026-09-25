import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/home/data/internship_model.dart';
import 'package:interna/features/home/presentation/home_screen.dart';
import 'package:interna/features/home/widgets/company_logo_widget.dart';
import 'package:interna/features/home/widgets/internship_card.dart';

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
}
