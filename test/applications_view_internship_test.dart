import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/applications/data/application_tracker_store.dart';
import 'package:interna/features/applications/presentation/application_tracker_screen.dart';

import 'package:interna/features/home/data/internship_model.dart';

void main() {
  testWidgets(
    'Verify Apply Now button is removed when View Internship is opened from Applications page',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // 1. Reset tracker store and apply for an opportunity
      ApplicationTrackerStore.instance.resetToDefaults();
      ApplicationTrackerStore.instance.applyForInternship(demoInternships.first);

      // 2. Pump ApplicationTrackerScreen
      await tester.pumpWidget(
        const MaterialApp(
          home: ApplicationTrackerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 3. Find and tap the "View Internship" button on the first application card
      final viewInternshipButton = find.text('View Internship').first;
      expect(viewInternshipButton, findsOneWidget);

      await tester.tap(viewInternshipButton);
      await tester.pumpAndSettle();

      // 4. Verify the internship details bottom sheet is opened
      expect(find.text('About the Internship'), findsOneWidget);
      expect(find.text('Requirements'), findsOneWidget);

      // 5. Confirm the "Apply Now" / "APPLY NOW" button is removed correctly
      expect(find.text('APPLY NOW'), findsNothing);
      expect(find.text('Apply Now'), findsNothing);
    },
  );
}
