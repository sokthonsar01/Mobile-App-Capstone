import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/validators.dart';
import '../auth_colors.dart';
import '../widgets/auth_widgets.dart';

/// The "Create an Account" screen. Front end only.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  validator: validateFullName,
                ),
                const SizedBox(height: 22),
                AuthTextField(
                  label: 'Email',
                  hint: 'maxverstappen1@gmail.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                const SizedBox(height: 22),
                AuthTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  isPassword: true,
                  // A new password is stricter than a login password:
                  // it also needs one letter and one number.
                  validator: validateNewPassword,
                ),
                const SizedBox(height: 18),
                _buildRememberRow(),
                const SizedBox(height: 24),
                PrimaryButton(text: 'SIGN UP', onPressed: _handleSignUp),
                const SizedBox(height: 16),
                GoogleButton(onPressed: _handleGoogleSignIn),
                const SizedBox(height: 20),
                BottomLinkRow(
                  question: 'Already have an account?',
                  linkText: 'Login',
                  onLinkTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRememberRow() {
    return Row(
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
            side: const BorderSide(color: AuthColors.border, width: 1.5),
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
    );
  }

  /// TODO(team): call the real sign up API here once a backend is chosen.
  void _handleSignUp() {
    if (!_formKey.currentState!.validate()) {
      _showMessage('Please fix the fields marked in red.');
      return;
    }

    debugPrint('SIGN UP pressed');
    debugPrint('full name: ${_fullNameController.text.trim()}');
    debugPrint('email: ${_emailController.text.trim()}');

    _showMessage('Sign up is not connected yet.');
  }

  void _handleGoogleSignIn() {
    _showMessage('Google sign in is not connected yet.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
