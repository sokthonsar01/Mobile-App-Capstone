import 'package:flutter/material.dart';

import '../auth_navigation.dart';
import '../widgets/auth_widgets.dart';
import 'reset_success_screen.dart';

/// "Check Your Email" screen. Front end only.
///
/// It is a StatelessWidget because nothing on it changes.
/// It only shows the email address that the screen before sent to it.
class CheckEmailScreen extends StatelessWidget {
  /// The email we show in the gray sentence.
  final String email;

  const CheckEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: kScreenPadding,
            vertical: 24,
          ),
          child: Column(
            children: [
              AuthHeader(
                title: 'Check Your Email',
                subtitle:
                    'We have sent the reset password to the email address\n'
                    '$email',
              ),

              const SizedBox(height: 40),

              Image.asset(
                'assets/images/illustration_mail_sent.png',
                height: 195,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 48),

              PrimaryButton(
                text: 'OPEN YOUR EMAIL',
                onPressed: () {
                  // TODO(team): in a real app this opens the phone mail app.
                  // For now it goes to the success screen so we can
                  // test the whole flow.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResetSuccessScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              PrimaryButton(
                text: 'BACK TO LOGIN',
                onPressed: () => backToLogin(context),
              ),

              const SizedBox(height: 20),

              BottomLinkRow(
                question: 'You have not received the email?',
                linkText: 'Resend',
                onLinkTap: () {
                  // TODO(team): send the email again once a backend is chosen.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resend is not connected yet.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
