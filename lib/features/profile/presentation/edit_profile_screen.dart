import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/app_navigation.dart';
import '../../../shared/theme/app_theme_controller.dart';
import '../../../shared/validators.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../data/user_profile_model.dart';
import '../widgets/profile_gender_selector.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_phone_field.dart';
import '../widgets/profile_settings_sheet.dart';

/// Comprehensive Internship Seeker Profile Screen.
/// Contains Academic Major, Resume/CV, Target Internship Roles,
/// Skills, and Personal Details for intelligent internship recommendations.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Personal Info Controllers
  late final TextEditingController _fullNameController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;

  // Education & Major Controllers
  late final TextEditingController _universityController;
  late final TextEditingController _majorController;
  late final TextEditingController _degreeLevelController;
  late final TextEditingController _gpaController;
  late final TextEditingController _gradYearController;

  // Target Roles & Preferences
  late String _preferredCategory;
  late String _workType;
  late List<String> _targetRoles;
  late List<String> _skills;

  String _gender = 'Male';
  String _countryCode = '+855';

  @override
  void initState() {
    super.initState();
    final p = currentDemoProfile;

    _fullNameController = TextEditingController(text: p.fullName);
    _birthDateController = TextEditingController(text: p.dateOfBirth);
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phone);
    _locationController = TextEditingController(text: p.location);

    _universityController = TextEditingController(text: p.university);
    _majorController = TextEditingController(text: p.major);
    _degreeLevelController = TextEditingController(text: p.degreeLevel);
    _gpaController = TextEditingController(text: p.gpa);
    _gradYearController = TextEditingController(text: p.graduationYear);

    _preferredCategory = p.preferredCategory;
    _workType = p.workType;
    _targetRoles = List<String>.from(p.targetRoles);
    _skills = List<String>.from(p.skills);
    _gender = p.gender;
    _countryCode = p.countryCode;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    _degreeLevelController.dispose();
    _gpaController.dispose();
    _gradYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.instance.themeModeNotifier,
      builder: (context, currentMode, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Profile Gradient Header with Photo & Major badge
                ProfileHeader(
              name: _fullNameController.text,
              location: _locationController.text,
              major: '${_majorController.text} • ${_universityController.text}',
              imageAsset: currentDemoProfile.avatarAsset,
              onShare: _handleShareProfile,
              onSettings: () => showProfileSettingsSheet(context),
              onChangeImage: _handleAvatarChange,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 36),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Academic & Major (Crucial for Recommendations)
                    _buildSectionCard(
                      title: 'Education & Academic Major',
                      icon: Icons.school_rounded,
                      iconColor: const Color(0xFF2B59FF),
                      subtitle:
                          'Your major helps us recommend high-match internships.',
                      children: [
                        SoftTextField(
                          label: 'University / Institute',
                          controller: _universityController,
                          validator: (v) =>
                              validateRequired(v, 'your university'),
                        ),
                        const SizedBox(height: 16),
                        SoftTextField(
                          label: 'Major / Field of Study',
                          controller: _majorController,
                          validator: (v) => validateRequired(v, 'your major'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: SoftTextField(
                                label: 'Degree & Year',
                                controller: _degreeLevelController,
                                validator: (v) =>
                                    validateRequired(v, 'degree level'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: SoftTextField(
                                label: 'GPA',
                                controller: _gpaController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SoftTextField(
                          label: 'Expected Graduation',
                          controller: _gradYearController,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Section 2: Resume / CV Document
                    _buildSectionCard(
                      title: 'Resume / CV Document',
                      icon: Icons.description_rounded,
                      iconColor: const Color(0xFFE11D48),
                      subtitle:
                          'Submitted with 1-tap when applying for internships.',
                      children: [
                        _buildResumeCard(),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Section 3: Target Internship Preferences
                    _buildSectionCard(
                      title: 'Internship Preferences',
                      icon: Icons.track_changes_rounded,
                      iconColor: const Color(0xFF0D9488),
                      subtitle:
                          'Select categories to power Home feed recommendations.',
                      children: [
                        Text(
                          'Target Roles',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.heading,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _targetRoles.map((role) {
                            return Chip(
                              label: Text(
                                role,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              backgroundColor: AppColors.isDark
                                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                                  : const Color(0xFFEFF4FF),
                              side: BorderSide(
                                color: AppColors.isDark
                                    ? const Color(0xFF1E40AF).withValues(alpha: 0.5)
                                    : const Color(0xFFDBEAFE),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Preferred Industry Category',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.heading,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildCategorySelector(),
                        const SizedBox(height: 16),
                        Text(
                          'Internship Work Mode',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.heading,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildWorkTypeSelector(),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Section 4: Skills & Tech Stack
                    _buildSectionCard(
                      title: 'Skills & Tech Stack',
                      icon: Icons.bolt_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      subtitle:
                          'Matched against employer internship requirements.',
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ..._skills.map((skill) {
                              return Chip(
                                label: Text(
                                  skill,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.heading,
                                  ),
                                ),
                                backgroundColor: AppColors.lightFill,
                                deleteIcon: Icon(Icons.close, size: 14, color: AppColors.hintText),
                                onDeleted: () {
                                  setState(() => _skills.remove(skill));
                                },
                                side: BorderSide(color: AppColors.cardBorder),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              );
                            }),
                            ActionChip(
                              avatar: const Icon(
                                Icons.add_circle_outline_rounded,
                                size: 16,
                                color: AppColors.primaryBlue,
                              ),
                              label: Text(
                                'Add Skill',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              backgroundColor: AppColors.surface,
                              side: const BorderSide(
                                color: AppColors.primaryBlue,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              onPressed: _showAddSkillDialog,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Section 5: Personal Information
                    _buildSectionCard(
                      title: 'Personal & Contact Info',
                      icon: Icons.person_rounded,
                      iconColor: const Color(0xFF6366F1),
                      subtitle: 'Basic details visible to verified recruiters.',
                      children: [
                        SoftTextField(
                          label: 'Fullname',
                          controller: _fullNameController,
                          validator: validateFullName,
                        ),
                        const SizedBox(height: 16),
                        SoftTextField(
                          label: 'Date of birth',
                          controller: _birthDateController,
                          readOnly: true,
                          onTap: _pickBirthDate,
                          suffix: Icon(
                            Icons.calendar_month_outlined,
                            color: AppColors.heading,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ProfileGenderSelector(
                          selectedGender: _gender,
                          onChanged: (String value) =>
                              setState(() => _gender = value),
                        ),
                        const SizedBox(height: 16),
                        SoftTextField(
                          label: 'Email address',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                        ),
                        const SizedBox(height: 16),
                        ProfilePhoneField(
                          countryCode: _countryCode,
                          controller: _phoneController,
                          onCountryCodeChanged: (String? newCode) {
                            if (newCode != null) {
                              setState(() => _countryCode = newCode);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        SoftTextField(
                          label: 'Location',
                          controller: _locationController,
                          validator: (String? value) =>
                              validateRequired(value, 'your location'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Save Profile Button
                    WideButton(
                      text: 'SAVE PROFILE',
                      onPressed: _handleSave,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: 4,
          onTap: (int index) => navigateToAppTab(context, 4, index),
        ),
      );
    },
  );
}

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.heading,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppColors.hintText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildResumeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.isDark
            ? const Color(0xFF4C0519).withValues(alpha: 0.25)
            : const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.isDark
              ? const Color(0xFF9F1239).withValues(alpha: 0.5)
              : const Color(0xFFFECDD3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentDemoProfile.cvFileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.isDark ? const Color(0xFFFDA4AF) : const Color(0xFF881337),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currentDemoProfile.cvFileSize} • Updated ${currentDemoProfile.cvLastUpdated}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppColors.isDark ? const Color(0xFFF43F5E) : const Color(0xFF9F1239),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ATS Ready',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showCvPreview,
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(
                    'Preview CV',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE11D48),
                    side: const BorderSide(color: Color(0xFFFDA4AF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handleReplaceCv,
                  icon: const Icon(Icons.upload_file_rounded, size: 16),
                  label: Text(
                    'Replace CV',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['IT', 'Design', 'Business', 'Finance'];

    return Row(
      children: categories.map((cat) {
        final isSelected = _preferredCategory == cat;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _preferredCategory = cat),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.cardBorder,
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.heading,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWorkTypeSelector() {
    final types = ['Full-time', 'Hybrid', 'Remote', 'Part-time'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = _workType.toLowerCase().contains(type.toLowerCase());
        return FilterChip(
          selected: isSelected,
          label: Text(
            type,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primaryBlue : AppColors.bodyText,
            ),
          ),
          selectedColor: AppColors.isDark
              ? const Color(0xFF1E3A8A).withValues(alpha: 0.35)
              : const Color(0xFFEFF4FF),
          backgroundColor: AppColors.surface,
          checkmarkColor: AppColors.primaryBlue,
          side: BorderSide(
            color: isSelected ? AppColors.primaryBlue : AppColors.cardBorder,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onSelected: (selected) {
            setState(() {
              _workType = selected ? '$type Internship' : 'Full-time Internship';
            });
          },
        );
      }).toList(),
    );
  }

  void _showAddSkillDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Add Skill',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: GoogleFonts.plusJakartaSans(color: AppColors.heading),
            decoration: InputDecoration(
              hintText: 'e.g. Kotlin, Node.js, SQL, Docker',
              hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.hintText),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(color: AppColors.hintText),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  setState(() => _skills.add(text));
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _handleAvatarChange() {
    _showMessage('Photo updated with Chhouen Ratanaksombo avatar.');
  }

  Future<void> _pickBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2003, 10, 15),
      firstDate: DateTime(1970),
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

    // Save to global user profile model
    currentDemoProfile.fullName = _fullNameController.text.trim();
    currentDemoProfile.university = _universityController.text.trim();
    currentDemoProfile.major = _majorController.text.trim();
    currentDemoProfile.degreeLevel = _degreeLevelController.text.trim();
    currentDemoProfile.gpa = _gpaController.text.trim();
    currentDemoProfile.graduationYear = _gradYearController.text.trim();
    currentDemoProfile.preferredCategory = _preferredCategory;
    currentDemoProfile.skills = _skills;
    currentDemoProfile.email = _emailController.text.trim();
    currentDemoProfile.phone = _phoneController.text.trim();
    currentDemoProfile.gender = _gender;
    currentDemoProfile.location = _locationController.text.trim();

    _showMessage(
      'Profile saved! Home recommendations tailored for ${_majorController.text}.',
    );
  }

  /// Copies a short profile summary so it can be pasted into a chat or email.
  Future<void> _handleShareProfile() async {
    final summary = [
      _fullNameController.text.trim(),
      '${_majorController.text.trim()} • ${_universityController.text.trim()}',
      if (_locationController.text.trim().isNotEmpty)
        _locationController.text.trim(),
      if (_skills.isNotEmpty) 'Skills: ${_skills.join(', ')}',
      if (_emailController.text.trim().isNotEmpty)
        'Email: ${_emailController.text.trim()}',
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: summary));
    _showMessage('Profile summary copied to clipboard.');
  }

  /// Lets the student pick a new PDF and shows it on the CV card.
  /// Only the local profile is updated here; uploading is done elsewhere.
  Future<void> _handleReplaceCv() async {
    final PlatformFile? file;
    try {
      file = await FilePicker.pickFile(
        dialogTitle: 'Select your CV (PDF)',
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
    } catch (_) {
      _showMessage('Could not open the file picker. Please try again.');
      return;
    }
    if (file == null) return; // User cancelled.

    final pickedName = file.name;
    final bytes = await file.xFile.length();
    if (!mounted) return;
    setState(() {
      currentDemoProfile.cvFileName = pickedName;
      currentDemoProfile.cvFileSize = _formatFileSize(bytes);
      currentDemoProfile.cvLastUpdated = _formatShortDate(DateTime.now());
    });
    _showMessage('CV replaced with $pickedName.');
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).ceil()} KB';
  }

  /// "Sep 27, 2026" — same style as the CV card's "Updated" date.
  String _formatShortDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Shows the details of the CV that is attached to applications.
  void _showCvPreview() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        Widget row(String label, String value) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.bodyText,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.heading,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your CV',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.heading,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                row('File name', currentDemoProfile.cvFileName),
                row('Size', currentDemoProfile.cvFileSize),
                row('Last updated', currentDemoProfile.cvLastUpdated),
                row('Used for', 'Every application you submit'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _handleReplaceCv();
                    },
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: const Text('Replace CV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B),
      ),
    );
  }
}
