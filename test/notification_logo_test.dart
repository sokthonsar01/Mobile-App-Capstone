import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/home/widgets/company_logo_widget.dart';
import 'package:interna/features/notifications/presentation/notifications_screen.dart';
import 'package:interna/shared/demo_data.dart';
import 'package:interna/shared/widgets/shared_widgets.dart';

void main() {
  testWidgets(
    'Notification displays the correct company logo from the internship posting company instead of default notification icon',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // 1. Pump the NotificationsScreen
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 2. Verify CompanyLogoWidget replaces the old default InitialsAvatar icon in notifications
      expect(find.byType(CompanyLogoWidget), findsWidgets);
      expect(find.byType(InitialsAvatar), findsNothing);

      // 3. Verify company logos in the notifications automatically match the internship posting companies
      final logoWidgets = tester
          .widgetList<CompanyLogoWidget>(find.byType(CompanyLogoWidget))
          .toList();
      expect(logoWidgets.isNotEmpty, isTrue);

      // Verify Hanuman notification displays Hanuman logo ('hanuman')
      expect(
        logoWidgets.any(
          (w) => w.companyName.contains('Hanuman') && w.logoKey == 'hanuman',
        ),
        isTrue,
      );

      // Verify Smart notification displays Smart logo ('smart')
      expect(
        logoWidgets.any(
          (w) => w.companyName.contains('Smart') && w.logoKey == 'smart',
        ),
        isTrue,
      );

      // Verify ABA notification displays ABA logo ('aba')
      expect(
        logoWidgets.any(
          (w) => w.companyName.contains('ABA') && w.logoKey == 'aba',
        ),
        isTrue,
      );

      // Verify Cellcard notification displays Cellcard logo ('cellcard')
      expect(
        logoWidgets.any(
          (w) => w.companyName.contains('Cellcard') && w.logoKey == 'cellcard',
        ),
        isTrue,
      );

      // Verify Chip Mong notification displays Chip Mong logo ('chip_mong')
      expect(
        logoWidgets.any(
          (w) => w.companyName.contains('Chip Mong') && w.logoKey == 'chip_mong',
        ),
        isTrue,
      );

      // 4. Verify automatic resolution directly from an AppNotification with only company name
      const customNotification = AppNotification(
        companyName: 'Chip Mong',
        title: 'Interview Call',
        body: 'You have a new interview scheduled.',
        timeAgo: 'Just now',
      );
      expect(customNotification.effectiveLogoKey, equals('chip_mong'));
      expect(customNotification.resolvedInternship?.company, equals('Chip Mong'));
    },
  );
}
