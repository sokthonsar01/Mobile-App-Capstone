import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../../shared/validators.dart';
// Your teammate's screen. We only open it, we never edit it.
import '../../home/presentation/home_screen.dart';
import '../auth_colors.dart';
import '../widgets/auth_widgets.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import 'dart:async';

/// The login screen.
///
/// Front end only. The buttons do not talk to any server yet.
/// When the team chooses a backend, we only change _handleLogin().
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// The key is how we talk to the Form below.
  /// `_formKey.currentState!.validate()` runs every field check at once
  /// and returns true only when all of them pass.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  // dispose() runs when the screen is closed.
  // Controllers hold memory, so we must clean them up here.


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
            // onUserInteraction: the red message updates while the user
            // fixes a field they already touched. Before they touch
            // anything, the screen stays clean.
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _buildTitle()),
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
                  validator: validateEmail,
                ),
                const SizedBox(height: 22),
                AuthTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  isPassword: true,
                  validator: validatePassword,
                ),
                const SizedBox(height: 18),
                _buildRememberRow(),
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
      ),
    );
  }

  /// "Welcome To" in black and "INTERNA" in blue, in one line.
  Widget _buildTitle() {
    return RichText(
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
    );
  }

  /// Checkbox on the left, "Forgot Password ?" on the right.
  Widget _buildRememberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
        ),
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
    );
  }

  // -------------------------------------------------------------------------
  // Button actions
  // -------------------------------------------------------------------------

  /// TODO(team): there is no backend yet, so we do not check the email and
  /// password against a server. We only check the fields are filled in,
  /// then open the home screen.
  ///
  /// When the backend is ready, call the login API here and open the home
  /// screen only after the server says the account is correct.
  void _handleLogin() {
    // validate() runs the check on every field inside the Form.
    // If any field fails, it draws the red message and returns false,
    // so we stop here.
    if (!_formKey.currentState!.validate()) {
      _showMessage('Please fix the fields marked in red.');
      return;
    }

    debugPrint('LOGIN pressed');
    debugPrint('email: ${_emailController.text.trim()}');
    debugPrint('remember me: $_rememberMe');

    _goToHome();
  }

  /// Opens the home screen and removes the login screen behind it.
  ///
  /// We use pushAndRemoveUntil, not push, on purpose. With a plain push the
  /// login screen would still be in the stack, so the phone back button
  /// would take a logged-in user back to the login form. Returning false
  /// for every old route removes all of them.
  void _goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  /// TODO(team): call Google Sign-In here once a backend is chosen.
  void _handleGoogleSignIn() {
    _showMessage('Google sign in is not connected yet.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? Uri.base.origin : 'io.supabase.interna://login-callback',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
      }
    }
  }

    late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

}
