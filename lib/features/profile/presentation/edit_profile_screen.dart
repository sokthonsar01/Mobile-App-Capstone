import 'package:flutter/material.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/validators.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../widgets/profile_gender_selector.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_phone_field.dart';
import '../widgets/profile_settings_sheet.dart';

/// Edit Profile screen.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController(
    text: 'Max Verstappen',
  );
  final TextEditingController _birthDateController = TextEditingController(
    text: '06 August 1992',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'maxverstappen1@gmail.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '99 946 638',
  );
  final TextEditingController _locationController = TextEditingController(
    text: 'Phnom Penh, Cambodia',
  );

  String _gender = 'Male';
  String _countryCode = '+855';

  @override
  void dispose() {
    _fullNameController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(
              name: 'Max Verstappen',
              location: 'Phnom Penh, Cambodia',
              onShare: () => _showMessage('Share is not built yet.'),
              onSettings: () => showProfileSettingsSheet(context),
              onChangeImage: () =>
                  _showMessage('Choosing an image is not built yet.'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SoftTextField(
                      label: 'Fullname',
                      controller: _fullNameController,
                      validator: validateFullName,
                    ),
                    const SizedBox(height: 20),
                    SoftTextField(
                      label: 'Date of birth',
                      controller: _birthDateController,
                      readOnly: true,
                      onTap: _pickBirthDate,
                      suffix: const Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.heading,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ProfileGenderSelector(
                      selectedGender: _gender,
                      onChanged: (String value) =>
                          setState(() => _gender = value),
                    ),
                    const SizedBox(height: 20),
                    SoftTextField(
                      label: 'Email address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 20),
                    ProfilePhoneField(
                      countryCode: _countryCode,
                      controller: _phoneController,
                      onCountryCodeChanged: (String? newCode) {
                        if (newCode != null) {
                          setState(() => _countryCode = newCode);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    SoftTextField(
                      label: 'Location',
                      controller: _locationController,
                      validator: (String? value) =>
                          validateRequired(value, 'your location'),
                    ),
                    const SizedBox(height: 40),
                    WideButton(text: 'SAVE', onPressed: _handleSave),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1992, 8, 6),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _birthDateController.text = _formatDate(picked);
    });
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final String day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}';
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      _showMessage('Please fix the fields marked in red.');
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showMessage('Please enter your phone number.');
      return;
    }

    debugPrint('SAVE pressed');
    debugPrint('name: ${_fullNameController.text}');
    debugPrint('birth: ${_birthDateController.text}');
    debugPrint('gender: $_gender');
    debugPrint('phone: $_countryCode ${_phoneController.text}');
    _showMessage('Saving is not connected yet.');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
