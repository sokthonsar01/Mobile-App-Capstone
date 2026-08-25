import 'package:flutter/material.dart';

import '../auth_navigation.dart';
import '../widgets/auth_widgets.dart';
import 'check_email_screen.dart';

/// "Forgot Password?" screen. Front end only.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthHeader(
                title: 'Forgot Password?',
                subtitle:
                    'To reset your password, you need your email or '
                    'mobile number that can be authenticated',
              ),

              const SizedBox(height: 40),

              Center(
                child: Image.asset(
                  'assets/images/illustration_key.png',
                  height: 170,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              AuthTextField(
                label: 'Email',
                hint: 'maxverstappen1@gmail.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 24),

              PrimaryButton(
                text: 'RESET PASSWORD',
                onPressed: _handleResetPassword,
              ),

              const SizedBox(height: 16),

              PrimaryButton(
                text: 'BACK TO LOGIN',
                onPressed: () => backToLogin(context),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// TODO(team): send the real reset email here once a backend is chosen.
  void _handleResetPassword() {
    debugPrint('RESET PASSWORD pressed for ${_emailController.text.trim()}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckEmailScreen(
          // If the user typed nothing, show the example email
          // so the next screen never looks empty.
          email: _emailController.text.trim().isEmpty
              ? 'brandonelouis@gmial.com'
              : _emailController.text.trim(),
        ),
      ),
    );
  }
}
