import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/company/data/company_model.dart';
import 'package:interna/features/company/presentation/screens/company_profile_screen.dart';

void main() {
  testWidgets('CompanyProfileScreen displays dynamic company data without dummy fallback',
      (tester) async {
    const liveCompany = Company(
      id: 'test-co-01',
      userId: 'u-01',
      name: 'CamTech Ventures',
      industry: 'Information Technology',
      contact: '+855 23 999 888',
      website: 'https://camtech.edu.kh',
      description: 'Pioneering technology and research education in Cambodia.',
      verified: true,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: CompanyProfileScreen(
          company: liveCompany,
        ),
      ),
    );

    await tester.pump();

    expect(find.text('CamTech Ventures'), findsWidgets);
    expect(find.text('INFORMATION TECHNOLOGY'), findsOneWidget);
    expect(find.text('+855 23 999 888'), findsOneWidget);
    expect(find.text('https://camtech.edu.kh'), findsOneWidget);
    expect(find.textContaining('Pioneering technology'), findsOneWidget);
    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
  });
}
