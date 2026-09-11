import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/validators.dart';
import '../../../shared/widgets/shared_widgets.dart';

/// Update Password screen. Front end only.
class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.black, size: 22),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 34),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        validator: (String? value) =>
                            validateRequired(value, 'your old password'),
                      ),
                      const SizedBox(height: 20),
                      SoftTextField(
                        label: 'New Password',
                        controller: _newPasswordController,
                        isPassword: true,
                        validator: validateNewPassword,
                      ),
                      const SizedBox(height: 20),
                      SoftTextField(
                        label: 'Confirm Password',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        // This one needs to see the other field, so we
                        // write a small function instead of passing a
                        // name directly.
                        validator: (String? value) => validateConfirmPassword(
                          value,
                          _newPasswordController.text,
                        ),
                      ),
                    ],
                  ),
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
  void _handleUpdate() {
    if (!_formKey.currentState!.validate()) {
      _showMessage('Please fix the fields marked in red.');
      return;
    }

    debugPrint('UPDATE pressed.');
    _showMessage('Updating the password is not connected yet.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
