import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../home/presentation/home_screen.dart';
import '../widgets/logout_sheet.dart';
import 'update_password_screen.dart';

/// Edit Profile screen: blue header on top, a form under it, SAVE at the end.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // We start the fields with the demo values from the mockup.
  final TextEditingController _fullNameController =
      TextEditingController(text: 'Max Verstappen');
  final TextEditingController _birthDateController =
      TextEditingController(text: '06 August 1992');
  final TextEditingController _emailController =
      TextEditingController(text: 'maxverstappen1@gmail.com');
  final TextEditingController _phoneController =
      TextEditingController(text: '99 946 638');
  final TextEditingController _locationController =
      TextEditingController(text: 'Phnom Penh, Cambodia');

  /// 'Male' or 'Female'. Controls which radio circle is filled.
  String _gender = 'Male';

  /// The country code shown in the small dropdown.
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
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SoftTextField(
                    label: 'Fullname',
                    controller: _fullNameController,
                  ),
                  const SizedBox(height: 20),
                  SoftTextField(
                    label: 'Date of birth',
                    controller: _birthDateController,
                    // readOnly stops the keyboard. The user picks a date
                    // from the calendar instead of typing it.
                    readOnly: true,
                    onTap: _pickBirthDate,
                    suffix: const Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildGenderRow(),
                  const SizedBox(height: 20),
                  SoftTextField(
                    label: 'Email address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  _buildPhoneRow(),
                  const SizedBox(height: 20),
                  SoftTextField(
                    label: 'Location',
                    controller: _locationController,
                  ),
                  const SizedBox(height: 40),
                  WideButton(text: 'SAVE', onPressed: _handleSave),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Header
  // -------------------------------------------------------------------------

  Widget _buildHeader() {
    // No fixed height on purpose.
    //
    // Before, this Container had `height: 220`. On a phone with a taller
    // status bar or a bigger system font, the avatar + name + button need
    // more than 220 and Flutter shows the yellow "BOTTOM OVERFLOWED" stripe.
    // With no height, the box grows to fit whatever is inside it.
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.headerBlueLight, AppColors.headerBlueDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            // min = be only as tall as the things inside.
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Back button on the left, Share and settings icons on the right.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showMessage('Share is not built yet.'),
                        icon: const Icon(Icons.reply_outlined,
                            color: Colors.white, size: 26),
                      ),
                      IconButton(
                        onPressed: _openSettingsMenu,
                        icon: const Icon(Icons.settings_outlined,
                            color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const InitialsAvatar(name: 'Max Verstappen', size: 60),
              const SizedBox(height: 10),
              Text(
                'Max Verstappen',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Phnom Penh, Cambodia',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // The soft "Change image" pill button.
              GestureDetector(
                onTap: () =>
                    _showMessage('Choosing an image is not built yet.'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Change image',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Gender
  // -------------------------------------------------------------------------

  Widget _buildGenderRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.heading,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _genderOption('Male')),
            const SizedBox(width: 16),
            Expanded(child: _genderOption('Female')),
          ],
        ),
      ],
    );
  }

  /// One white box with a circle and a word inside.
  Widget _genderOption(String value) {
    final bool isSelected = _gender == value;

    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: softShadow,
        ),
        child: Row(
          children: [
            // The circle. Blue ring + blue dot when selected.
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.heading,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                color: AppColors.heading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Phone number (country code + number in one white box)
  // -------------------------------------------------------------------------

  Widget _buildPhoneRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone number',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.heading,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: softShadow,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: DropdownButton<String>(
                  value: _countryCode,
                  // Removes the default underline so it matches the design.
                  underline: const SizedBox.shrink(),
                  items: const ['+855', '+66', '+84', '+1']
                      .map((code) => DropdownMenuItem<String>(
                            value: code,
                            child: Text(code),
                          ))
                      .toList(),
                  onChanged: (String? newCode) {
                    if (newCode == null) return;
                    setState(() => _countryCode = newCode);
                  },
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: AppColors.heading,
                  ),
                ),
              ),
              // The thin gray line between the code and the number.
              Container(width: 1, height: 26, color: AppColors.border),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: AppColors.heading,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  /// Opens the calendar that comes with Flutter. No extra package needed.
  Future<void> _pickBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1992, 8, 6),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    // mounted is true only while the screen is still on the display.
    // We check it because we used await above and the user may have left.
    if (!mounted) return;

    setState(() {
      _birthDateController.text = _formatDate(picked);
    });
  }

  /// Turns a DateTime into "06 August 1992".
  String _formatDate(DateTime date) {
    const List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    // padLeft(2, '0') turns 6 into "06".
    final String day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}';
  }

  void _openSettingsMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Update password'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpdatePasswordScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.danger),
                title: const Text('Log out'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showLogoutSheet(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// TODO(team): send the profile to the server once a backend is chosen.
  void _handleSave() {
    debugPrint('SAVE pressed');
    debugPrint('name: ${_fullNameController.text}');
    debugPrint('birth: ${_birthDateController.text}');
    debugPrint('gender: $_gender');
    debugPrint('phone: $_countryCode ${_phoneController.text}');
    _showMessage('Saving is not connected yet.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
