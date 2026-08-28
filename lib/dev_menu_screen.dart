import 'package:flutter/material.dart';

import 'features/auth/presentation/check_email_screen.dart';
import 'features/auth/presentation/forgot_password_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/onboarding_screen.dart';
import 'features/auth/presentation/reset_success_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/home/presentation/offline_error_screen.dart';
import 'features/messages/presentation/chat_screen.dart';
import 'features/messages/presentation/messages_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/profile/presentation/edit_profile_screen.dart';
import 'features/profile/presentation/update_password_screen.dart';
import 'features/profile/widgets/logout_sheet.dart';
import 'features/saved/presentation/saved_internships_screen.dart';

/// A temporary menu so we can open every screen and check it.
///
/// This screen is ONLY for testing. It is not part of the real app.
/// Delete this file before the final submission.
class DevMenuScreen extends StatelessWidget {
  const DevMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev menu (delete before submit)'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Main App / Dashboard'),
          _open(
            context,
            '★ Home / Internship Explorer',
            const HomeScreen(),
          ),
          _open(
            context,
            '★ No Connection / Offline Error State',
            const OfflineErrorScreen(),
          ),

          const _SectionTitle('Auth flow'),
          _open(context, '1. Onboarding', const OnboardingScreen()),
          _open(context, '2. Login', const LoginScreen()),
          _open(context, '3. Sign up', const SignupScreen()),
          _open(context, '4. Forgot password', const ForgotPasswordScreen()),
          _open(
            context,
            '5. Check your email',
            const CheckEmailScreen(email: 'maxverstappen1@gmail.com'),
          ),
          _open(context, '6. Successfully', const ResetSuccessScreen()),

          const _SectionTitle('Profile'),
          _open(context, '7. Edit profile', const EditProfileScreen()),
          _open(context, '8. Update password', const UpdatePasswordScreen()),
          ListTile(
            title: const Text('9. Log out sheet'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLogoutSheet(context),
          ),

          const _SectionTitle('Messages'),
          _open(context, '10. Messages list', const MessagesScreen()),
          _open(
            context,
            '11. Chat',
            const ChatScreen(contactName: 'Taylor Swift'),
          ),

          const _SectionTitle('Other'),
          _open(
            context,
            '12. Saved internships',
            const SavedInternshipsScreen(),
          ),
          _open(context, '13. Notifications', const NotificationsScreen()),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Builds one row that opens a screen when you tap it.
  /// We wrote it once here instead of copying ListTile 12 times.
  Widget _open(BuildContext context, String label, Widget screen) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }
}

/// The small gray group heading inside the list.
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
