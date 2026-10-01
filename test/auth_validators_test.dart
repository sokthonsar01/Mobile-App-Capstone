import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/auth/presentation/signup_screen.dart';
import 'package:interna/features/auth/widgets/auth_widgets.dart';
import 'package:interna/shared/validators.dart';

void main() {
  group('Auth Name Validators', () {
    test('validateFirstName checks emptiness and min length', () {
      expect(validateFirstName(null), 'Please enter your first name.');
      expect(validateFirstName(''), 'Please enter your first name.');
      expect(validateFirstName('   '), 'Please enter your first name.');
      expect(validateFirstName('A'), 'First name must be at least 2 characters.');
      expect(validateFirstName('Max'), isNull);
    });

    test('validateLastName checks emptiness and min length', () {
      expect(validateLastName(null), 'Please enter your last name.');
      expect(validateLastName(''), 'Please enter your last name.');
      expect(validateLastName('   '), 'Please enter your last name.');
      expect(validateLastName('V'), 'Last name must be at least 2 characters.');
      expect(validateLastName('Verstappen'), isNull);
    });
  });

  group('PrimaryButton Widget', () {
    testWidgets('shows text when isLoading is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'SUBMIT',
              isLoading: false,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('SUBMIT'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows spinner when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'SUBMIT',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('SUBMIT'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('SignupScreen UI', () {
    testWidgets('renders first name, last name, and validates inputs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignupScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify fields exist matching backend schema
      expect(find.text('First name'), findsOneWidget);
      expect(find.text('Last name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('SIGN UP'), findsOneWidget);

      // Tap SIGN UP without entering values
      await tester.tap(find.text('SIGN UP'));
      await tester.pumpAndSettle();

      // Check validation errors are triggered
      expect(find.text('Please enter your first name.'), findsOneWidget);
      expect(find.text('Please enter your last name.'), findsOneWidget);
      expect(find.text('Please enter your email address.'), findsOneWidget);
    });
  });
}
