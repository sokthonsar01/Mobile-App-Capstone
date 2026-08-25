import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';

/// Update Password screen. Front end only.
class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back arrow.
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.black, size: 22),
              ),
            ),

            // Expanded pushes the UPDATE button to the bottom,
            // like in the design.
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Password',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SoftTextField(
                      label: 'Old Password',
                      controller: _oldPasswordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),
                    SoftTextField(
                      label: 'New Password',
                      controller: _newPasswordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),
                    SoftTextField(
                      label: 'Confirm Password',
                      controller: _confirmPasswordController,
                      isPassword: true,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(34, 16, 34, 40),
              child: WideButton(text: 'UPDATE', onPressed: _handleUpdate),
            ),
          ],
        ),
      ),
    );
  }

  /// TODO(team): send the new password to the server once a backend exists.
  ///
  /// I added one small check here on purpose: the two new passwords must
  /// match. That check is front end work, not backend work.
  void _handleUpdate() {
    final String newPassword = _newPasswordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      _showMessage('The two new passwords are not the same.');
      return;
    }

    debugPrint('UPDATE pressed. New password length: ${newPassword.length}');
    _showMessage('Updating the password is not connected yet.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
