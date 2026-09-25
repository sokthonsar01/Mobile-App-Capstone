import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/home/presentation/application_tracker_screen.dart';

void main() {
  testWidgets('Tracker buttons and status actions (View Details, Withdraw, Decline) work correctly', (WidgetTester tester) async {
    // 1. Pump ApplicationTrackerScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: ApplicationTrackerScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 2. Test "View Internship" button
    expect(find.text('View Internship'), findsWidgets);
    await tester.tap(find.text('View Internship').first);
    await tester.pumpAndSettle();

    // Verify Internship Details Sheet opened
    expect(find.text('About the Internship'), findsOneWidget);
    // Dismiss sheet
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // 3. Test "View Details" button for an Under Review application
    expect(find.text('View Details'), findsWidgets);
    await tester.tap(find.text('View Details').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify Details modal loaded with dates, timeline, and Withdraw action
    expect(find.text('Application Progress Timeline'), findsOneWidget);
    expect(find.text('Date Applied'), findsOneWidget);
    expect(find.text('Last Updated'), findsOneWidget);
    expect(find.text('Withdraw'), findsOneWidget);

    // 4. Test Withdraw Application action & Confirmation Dialog
    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle();

    expect(find.text('Withdraw Application'), findsOneWidget);

    // Confirm withdrawal
    await tester.tap(find.widgetWithText(ElevatedButton, 'Withdraw'));
    await tester.pumpAndSettle();

    // Verify application status changed to Withdrawn
    expect(find.text('Withdrawn'), findsWidgets);
    expect(find.byType(SnackBar), findsOneWidget);

    // Fast-forward SnackBar timer
    await tester.pump(const Duration(seconds: 4));

    // 5. Test "Offer" filter chip & "Decline Offer"
    await tester.ensureVisible(find.byKey(const Key('filter_Offer')));
    await tester.tap(find.byKey(const Key('filter_Offer')), warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.text('View Details').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Decline Offer'), findsOneWidget);

    await tester.tap(find.text('Decline Offer'));
    await tester.pumpAndSettle();

    expect(find.text('Decline Offer'), findsWidgets);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Decline'));
    await tester.pumpAndSettle();

    expect(find.text('Withdrawn'), findsWidgets);

    // Fast-forward SnackBar timer
    await tester.pump(const Duration(seconds: 4));

    // 6. Test "Rejected" filter chip -> View Details has NO withdraw/decline action button
    await tester.ensureVisible(find.byKey(const Key('filter_Rejected')));
    await tester.tap(find.byKey(const Key('filter_Rejected')), warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.text('View Details').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Withdraw'), findsNothing);
    expect(find.text('Decline Offer'), findsNothing);
    expect(find.text('Close'), findsOneWidget);
  });
}
