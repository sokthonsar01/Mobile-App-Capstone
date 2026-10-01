import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/profile/presentation/edit_profile_screen.dart';
import 'package:interna/features/profile/widgets/profile_header.dart';
import 'package:interna/shared/widgets/shared_widgets.dart';

void main() {
  testWidgets('EditProfileScreen renders ProfileHeader with avatar and camera icon',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EditProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProfileHeader), findsOneWidget);
    expect(find.byType(InitialsAvatar), findsWidgets);
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
  });
}
