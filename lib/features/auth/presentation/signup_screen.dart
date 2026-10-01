import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/validators.dart';
import '../../home/presentation/home_screen.dart';
import '../widgets/auth_widgets.dart';

/// The "Create an Account" screen.
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

  bool _rememberMe = false;
  bool _isLoading = false;

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
                    isLoading: _isLoading,
                    onPressed: _handleSignUp,
                  ),
                  const SizedBox(height: 16),
                  GoogleButton(
                    onPressed: _isLoading ? () {} : _handleGoogleSignIn,
                  ),
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
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) {
      _showMessage('Please fix the fields marked in red.');
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'name': '$firstName $lastName',
        },
      );

      if (!mounted) return;

      if (response.session != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showMessage(
          'Account created! Please check your email to verify your account.',
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showMessage(e.message);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Sign up failed. Please check your network connection.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            kIsWeb ? Uri.base.origin : 'io.supabase.interna://login-callback',
      );
    } on AuthException catch (e) {
      if (mounted) {
        _showMessage(e.message);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Google Sign-In failed. Please check your connection.');
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
