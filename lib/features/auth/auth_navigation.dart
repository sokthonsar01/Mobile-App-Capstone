import 'package:flutter/material.dart';

import 'presentation/login_screen.dart';

/// Opens the login screen and removes every screen behind it.
///
/// Three screens have a "BACK TO LOGIN" button. Without this helper we
/// would copy the same 6 lines into all three of them.
void backToLogin(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    // Returning false for every old route means: remove all of them.
    // So the user cannot press the back arrow into the reset flow again.
    (Route<dynamic> route) => false,
  );
}
