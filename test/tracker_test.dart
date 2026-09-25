import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/home/data/application_tracker_store.dart';
import 'package:interna/features/home/data/internship_model.dart';
import 'package:interna/features/home/presentation/application_tracker_screen.dart';

void main() {
  testWidgets('Persistent tracker data flow: apply -> appears in Tracker -> withdraw -> status stays saved -> withdrawn card removed', (WidgetTester tester) async {
    // 1. Reset tracker store to initial state
    ApplicationTrackerStore.instance.resetToDefaults();

    // 2. Select an internship item (Hanuman) and apply for it
    final newInternship = demoInternships.firstWhere((e) => e.logoKey == 'hanuman');
    final applied = ApplicationTrackerStore.instance.applyForInternship(newInternship);
    expect(applied, isTrue);

    // 3. Pump ApplicationTrackerScreen and verify new application appears with status "Applied"
    await tester.pumpWidget(
      const MaterialApp(
        home: ApplicationTrackerScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hanuman'), findsOneWidget);
    expect(find.text('Applied'), findsWidgets);

    // 4. Open "Applied" filter tab to find Hanuman card easily
    await tester.tap(find.byKey(const Key('filter_Applied')));
    await tester.pumpAndSettle();

    expect(find.text('Hanuman'), findsOneWidget);

    // 5. Tap "View Details" on the Hanuman card and Withdraw
    await tester.tap(find.text('View Details').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Withdraw'), findsOneWidget);
    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle();

    // Confirm withdrawal in AlertDialog
    expect(find.text('Withdraw Application'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Withdraw'));
    await tester.pumpAndSettle();

    // Fast forward SnackBar timer
    await tester.pump(const Duration(seconds: 4));

    // 6. Verify status updated to "Withdrawn" and stays saved after leaving & returning to page
    expect(find.text('Withdrawn'), findsWidgets);

    // Re-pump screen to simulate returning to Tracker page
    await tester.pumpWidget(
      const MaterialApp(
        home: ApplicationTrackerScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Filter by Withdrawn
    await tester.ensureVisible(find.byKey(const Key('filter_Withdrawn')));
    await tester.tap(find.byKey(const Key('filter_Withdrawn')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Hanuman'), findsOneWidget);
    expect(find.text('Withdrawn'), findsWidgets);

    // 7. Test removing the withdrawn card from history
    expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);
    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Remove from Tracker'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Remove'));
    await tester.pumpAndSettle();

    // Verify Hanuman card has been removed from history
    expect(find.text('Hanuman'), findsNothing);
  });
}
