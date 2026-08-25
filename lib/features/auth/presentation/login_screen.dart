import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth_colors.dart';
import '../widgets/auth_widgets.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

/// The login screen.
///
/// This screen is front end only. The buttons do not talk to any server yet.
/// When the team chooses a backend, we only change the small
/// _handleLogin() method at the bottom. Nothing else has to move.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers give us the text the user typed.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// true when the "Remember me" box is ticked.
  bool _rememberMe = false;

  // dispose() runs when the screen is closed.
  // Controllers hold memory, so we must clean them up here.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // SingleChildScrollView stops the "bottom overflowed" red error
        // when the keyboard opens or the phone screen is small.
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: kScreenPadding,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title: "Welcome To" is black, "INTERNA" is blue.
              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                    children: const [
                      TextSpan(text: 'Welcome To '),
                      TextSpan(
                        text: 'INTERNA',
                        style: TextStyle(color: AuthColors.primaryBlue),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Image.asset(
                  'assets/images/illustration_intern.png',
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

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

              // Row with the checkbox on the left and the link on the right.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRememberMe(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password ?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AuthColors.heading,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              PrimaryButton(text: 'LOGIN', onPressed: _handleLogin),

              const SizedBox(height: 16),

              GoogleButton(onPressed: _handleGoogleSignIn),

              const SizedBox(height: 20),

              BottomLinkRow(
                question: "You don't have an account yet?",
                linkText: 'Sign up',
                onLinkTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The small square box + the words "Remember me".
  Widget _buildRememberMe() {
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (bool? newValue) {
              // newValue can be null, so we use "?? false" as a safe default.
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

  // -------------------------------------------------------------------------
  // Button actions. Front end only for now.
  // -------------------------------------------------------------------------

  /// TODO(team): call the real login API here once a backend is chosen.
  void _handleLogin() {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    debugPrint('LOGIN pressed');
    debugPrint('email: $email');
    debugPrint('password length: ${password.length}');
    debugPrint('remember me: $_rememberMe');

    _showMessage('Login is not connected yet.');
  }

  /// TODO(team): call Google Sign-In here once a backend is chosen.
  void _handleGoogleSignIn() {
    _showMessage('Google sign in is not connected yet.');
  }

  /// Shows a short gray bar at the bottom of the screen.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
