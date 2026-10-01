import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/validators.dart';
import '../../home/presentation/home_screen.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../widgets/auth_widgets.dart';

/// The "Create an Account" screen implemented with MVVM pattern using [AuthViewModel].
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthViewModel _authViewModel = AuthViewModel.instance;
  bool _rememberMe = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: kScreenPadding,
              vertical: 24,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListenableBuilder(
                listenable: _authViewModel,
                builder: (context, _) {
                  return Column(
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
                      const SizedBox(height: 36),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AuthTextField(
                              label: 'First name',
                              hint: 'Max',
                              controller: _firstNameController,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              validator: validateFirstName,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AuthTextField(
                              label: 'Last name',
                              hint: 'Verstappen',
                              controller: _lastNameController,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              validator: validateLastName,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        label: 'Email',
                        hint: 'maxverstappen1@gmail.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleSignUp(),
                        validator: validateNewPassword,
                      ),
                      const SizedBox(height: 18),
                      _buildRememberRow(),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'SIGN UP',
                        isLoading: _authViewModel.isLoading,
                        onPressed: _handleSignUp,
                      ),
                      const SizedBox(height: 16),
                      GoogleButton(
                        onPressed: _authViewModel.isLoading
                            ? () {}
                            : _handleGoogleSignIn,
                      ),
                      const SizedBox(height: 20),
                      BottomLinkRow(
                        question: 'Already have an account?',
                        linkText: 'Login',
                        onLinkTap: () => Navigator.pop(context),
                      ),
                    ],
                  );
                },
              ),
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
            activeColor: AppColors.primaryBlue,
            side: BorderSide(color: AppColors.border, width: 1.5),
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
            color: AppColors.hintText,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignUp() async {
    if (_authViewModel.isLoading) return;
    if (!_formKey.currentState!.validate()) {
      _showMessage('Please fix the fields marked in red.');
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final status = await _authViewModel.signUpWithEmail(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );

    if (!mounted) return;

    switch (status) {
      case AuthSignUpStatus.authenticated:
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
          (route) => false,
        );
        break;
      case AuthSignUpStatus.needsEmailConfirmation:
        _showMessage(
          'Account created! Please check your email to verify your account.',
        );
        Navigator.pop(context);
        break;
      case AuthSignUpStatus.alreadyExists:
      case AuthSignUpStatus.failed:
        final error =
            _authViewModel.errorMessage ?? 'Sign up failed. Please try again.';
        _showMessage(error);
        break;
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_authViewModel.isLoading) return;
    final success = await _authViewModel.signInWithGoogle();
    if (!mounted) return;
    if (!success) {
      final error = _authViewModel.errorMessage;
      if (error != null) {
        _showMessage(error);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
