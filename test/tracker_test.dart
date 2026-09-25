import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/home/presentation/application_tracker_screen.dart';

void main() {
  testWidgets('ApplicationTrackerScreen loads and functions without errors', (WidgetTester tester) async {
    // 1. Pump ApplicationTrackerScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: ApplicationTrackerScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 2. Verify Page Title and Header Subtitle
    expect(find.text('Application Tracker'), findsOneWidget);
    expect(find.text('Track & manage your internship applications'), findsOneWidget);

    // 3. Verify Top Summary Metrics Cards
    expect(find.text('Applied'), findsWidgets);
    expect(find.text('Under Review'), findsWidgets);
    expect(find.text('Interview'), findsWidgets);
    expect(find.text('Offer'), findsWidgets);

    // 4. Verify Application Cards & Progress Stepper stages
    expect(find.text('Applied: Jan 15, 2026'), findsOneWidget);
    expect(find.text('View Internship'), findsWidgets);
    expect(find.text('Update Status'), findsWidgets);

    // 5. Test Filter Tabs Interaction
    await tester.tap(find.text('Offer').first);
    await tester.pumpAndSettle();
    expect(find.text('Offer'), findsWidgets);

    // Switch back to All
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // 6. Test Update Status Modal Sheet
    await tester.tap(find.text('Update Status').first);
    await tester.pumpAndSettle();

    expect(find.text('Update Application Status'), findsOneWidget);

    // Select 'Interview' status
    await tester.tap(find.text('Interview').last);
    await tester.pumpAndSettle();

    // Confirm SnackBar appears and status updated
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
