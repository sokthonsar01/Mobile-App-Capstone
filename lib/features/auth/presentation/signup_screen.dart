import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth_colors.dart';
import '../widgets/auth_widgets.dart';

/// The "Create an Account" screen. Front end only.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
                title: 'Create an Account',
                subtitle:
                    'Your journey from the classroom to the boardroom '
                    'starts here. Join a community of ambitious students '
                    'and get matched with top-tier internships that '
                    'actually fit your major and your schedule.',
              ),

              const SizedBox(height: 48),

              AuthTextField(
                label: 'Full name',
                hint: 'Max Verstappen',
                controller: _fullNameController,
                keyboardType: TextInputType.name,
              ),

              const SizedBox(height: 22),

              AuthTextField(
                label: 'Email',
                hint: 'maxverstappen1@gmail.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 22),

              AuthTextField(
                label: 'Password',
                hint: 'Enter your password',
                controller: _passwordController,
                isPassword: true,
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (bool? newValue) {
                        setState(() => _rememberMe = newValue ?? false);
                      },
                      activeColor: AuthColors.primaryBlue,
                      side: const BorderSide(
                        color: AuthColors.border,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Remember me',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AuthColors.hintText,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              PrimaryButton(text: 'SIGN UP', onPressed: _handleSignUp),

              const SizedBox(height: 16),

              GoogleButton(onPressed: _handleGoogleSignIn),

              const SizedBox(height: 20),

              BottomLinkRow(
                question: 'Already have an account?',
                linkText: 'Login',
                onLinkTap: () {
                  // We came here from the login screen, so pop() goes back.
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// TODO(team): call the real sign up API here once a backend is chosen.
  void _handleSignUp() {
    debugPrint('SIGN UP pressed');
    debugPrint('full name: ${_fullNameController.text.trim()}');
    debugPrint('email: ${_emailController.text.trim()}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign up is not connected yet.')),
    );
  }

  void _handleGoogleSignIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google sign in is not connected yet.')),
    );
  }
}
