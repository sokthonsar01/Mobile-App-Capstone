import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/home/presentation/home_screen.dart';
import 'package:interna/features/home/presentation/offline_error_screen.dart';

void main() {
  testWidgets('HomeScreen full smoke and interaction test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // 1. Check Header & Top Banner
    expect(find.text('Welcome back, Max!'), findsOneWidget);
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

    // 5. Test "View Details" Bottom Sheet
    await tester.tap(find.text('View Details').first);
    await tester.pumpAndSettle();

    expect(find.text('About the Internship'), findsOneWidget);
    expect(find.text('APPLY NOW'), findsOneWidget);
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
}
