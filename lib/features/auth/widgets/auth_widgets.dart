import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth_colors.dart';

/// Space on the left and right side of every auth screen.
/// Taken from the design: the content starts about 44 pixels from the edge.
const double kScreenPadding = 44;

/// Height of the blue buttons in the design.
const double kButtonHeight = 50;

// ---------------------------------------------------------------------------
// 1. Text field with a label on top
// ---------------------------------------------------------------------------

/// A label (like "Email") with a bordered text box under it.
///
/// It is a StatefulWidget because the password field needs to remember
/// whether the password is hidden or shown when you tap the eye icon.
class AuthTextField extends StatefulWidget {
  /// The bold text above the box, for example "Email".
  final String label;

  /// The gray example text inside the empty box.
  final String hint;

  /// Holds what the user types. The screen creates it and reads it later.
  final TextEditingController controller;

  /// true = hide the letters and show an eye icon.
  final bool isPassword;

  /// Changes the phone keyboard (for example, show "@" for email).
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  /// true = the password is covered with dots.
  /// It starts as true, like in the design.
  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AuthColors.heading,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          // Hide the letters only when this is a password AND the eye is off.
          obscureText: widget.isPassword && _isHidden,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            color: AuthColors.heading,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: AuthColors.hintText,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            enabledBorder: _buildBorder(AuthColors.border),
            focusedBorder: _buildBorder(AuthColors.primaryBlue),
            // Show the eye icon only on password fields.
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isHidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AuthColors.heading,
                      size: 22,
                    ),
                    // setState tells Flutter to draw this widget again
                    // with the new value of _isHidden.
                    onPressed: () => setState(() => _isHidden = !_isHidden),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  /// Both borders look the same, only the color changes.
  /// So we build them with one small helper instead of copying the code.
  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Blue filled button (LOGIN, SIGN UP, RESET PASSWORD, ...)
// ---------------------------------------------------------------------------

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: kButtonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. White "Sign in with Google" button
// ---------------------------------------------------------------------------

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: kButtonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AuthColors.primaryBlue,
          side: const BorderSide(color: AuthColors.primaryBlue, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google_logo.png',
              height: 20,
              width: 20,
            ),
            const SizedBox(width: 14),
            Text(
              'SIGN IN WITH GOOGLE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Bottom line: "You don't have an account yet?  Sign up"
// ---------------------------------------------------------------------------

class BottomLinkRow extends StatelessWidget {
  /// The normal gray question, for example "You don't have an account yet?".
  final String question;

  /// The blue underlined word, for example "Sign up".
  final String linkText;

  final VoidCallback onLinkTap;

  const BottomLinkRow({
    super.key,
    required this.question,
    required this.linkText,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AuthColors.bodyText,
          ),
        ),
        const SizedBox(width: 8),
        // GestureDetector makes normal text tappable.
        GestureDetector(
          onTap: onLinkTap,
          child: Text(
            linkText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AuthColors.primaryBlue,
              decoration: TextDecoration.underline,
              decorationColor: AuthColors.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Page title + gray sentence under it
// ---------------------------------------------------------------------------

class AuthHeader extends StatelessWidget {
  final String title;

  /// The gray sentence under the title. Pass null when there is none.
  final String? subtitle;

  const AuthHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AuthColors.heading,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              height: 1.6,
              color: AuthColors.bodyText,
            ),
          ),
        ],
      ],
    );
  }
}
