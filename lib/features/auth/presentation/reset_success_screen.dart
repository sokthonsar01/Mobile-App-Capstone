import 'package:flutter/material.dart';

import '../auth_navigation.dart';
import '../widgets/auth_widgets.dart';

/// "Successfully" screen, shown after the password was changed.
/// Front end only.
class ResetSuccessScreen extends StatelessWidget {
  const ResetSuccessScreen({super.key});

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
              const AuthHeader(
                title: 'Successfully',
                subtitle:
                    'Your password has been updated, please change your '
                    'password regularly to avoid this happening',
              ),

              const SizedBox(height: 48),

              Image.asset(
                'assets/images/illustration_success.png',
                height: 185,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 56),

              PrimaryButton(
                text: 'CONTINUE',
                onPressed: () {
                  // TODO(team): change this to the home screen
                  // when someone builds it. For now we go to login.
                  backToLogin(context);
                },
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
}
