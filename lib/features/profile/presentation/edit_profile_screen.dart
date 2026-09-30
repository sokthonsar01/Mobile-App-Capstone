import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../shared/app_colors.dart';
import '../../../shared/app_navigation.dart';
import '../../../shared/theme/app_theme_controller.dart';
import '../../../shared/validators.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../data/student_profile.model.dart';
import '../data/student_repository.dart';
import '../data/user_profile_model.dart';
import '../widgets/logout_sheet.dart';
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

  final ScrollController _scrollController = ScrollController();

  bool _isSaving = false;
  bool _isEditing = false;
  StudentProfile? _backendProfile;
  DateTime? _selectedDob;

  String? _cvFileName;
  String? _cvFileSize;
  String? _cvLastUpdated;

  void _startEditing({bool scrollToTop = false}) {
    if (scrollToTop && _scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    setState(() => _isEditing = false);
    _loadBackendProfile();
  }

  void _showEditConfirmationDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Edit Profile Information?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.heading,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'You can modify your academic details, contact information, target preferences, skills, and CV document.\n\nNote: Your verified login email remains locked to your account.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.bodyText,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Keep Viewing',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.heading,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _startEditing(scrollToTop: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Start Editing',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  sb.User? get _currentAuthUser {
    try {
      return sb.Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    final authUser = _currentAuthUser;
    final meta = authUser?.userMetadata ?? {};
    final authName = (meta['full_name'] ?? meta['name'] ?? '').toString();
    final authEmail = authUser?.email ?? '';
    final authPhone = (authUser?.phone ?? meta['phone'] ?? '').toString();

    _fullNameController = TextEditingController(text: authName);
    _birthDateController = TextEditingController();
    _emailController = TextEditingController(text: authEmail);
    _phoneController = TextEditingController(text: authPhone);
    _locationController = TextEditingController();

    _universityController = TextEditingController();
    _majorController = TextEditingController();
    _degreeLevelController = TextEditingController();
    _gpaController = TextEditingController();
    _gradYearController = TextEditingController();

    _preferredCategory = 'Tech';
    _workType = 'Full-Time';
    _targetRoles = [];
    _skills = [];
    _gender = 'Male';
    _countryCode = '+855';

    _loadBackendProfile();
  }

  Future<void> _loadBackendProfile() async {
    try {
      final profile = await StudentRepository.getMyProfile();
      if (profile != null && mounted) {
        setState(() {
          _backendProfile = profile;
          if (profile.getFullName.isNotEmpty) {
            _fullNameController.text = profile.getFullName;
          }
          if (profile.currentAddress.isNotEmpty) {
            _locationController.text = profile.currentAddress;
          }
          if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) {
            _phoneController.text = profile.phoneNumber!;
          }
          if (profile.dob != null) {
            _selectedDob = profile.dob;
            _birthDateController.text = _formatDate(profile.dob!);
          }
          if (profile.gender.isNotEmpty) {
            _gender = profile.gender == 'MALE'
                ? 'Male'
                : (profile.gender == 'FEMALE' ? 'Female' : 'Other');
          }
          if (profile.description != null && profile.description!.contains('student at')) {
            final parts = profile.description!.split('student at');
            if (_majorController.text.isEmpty && parts.isNotEmpty) {
              _majorController.text = parts.first.trim();
            }
            if (_universityController.text.isEmpty && parts.length > 1) {
              _universityController.text = parts[1].trim();
            }
          }
        });
      }
    } catch (_) {
      // Gracefully maintain authenticated user fields
    }
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = _currentAuthUser;
    final metadata = authUser?.userMetadata ?? {};
    final avatarUrl = _backendProfile?.avatarUrl ??
        metadata['avatar_url'] as String? ??
        metadata['picture'] as String?;
    final displayName = _fullNameController.text.trim().isNotEmpty
        ? _fullNameController.text.trim()
        : (metadata['full_name'] ?? metadata['name'] ?? (authUser?.email?.split('@').first ?? 'My Profile')).toString();
    final locationText = _locationController.text.trim().isNotEmpty
        ? _locationController.text.trim()
        : 'Cambodia';
    final academicText = _majorController.text.trim().isNotEmpty
        ? '${_majorController.text.trim()}${_universityController.text.trim().isNotEmpty ? " • ${_universityController.text.trim()}" : ""}'
        : 'Internship Seeker';

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.instance.themeModeNotifier,
      builder: (context, currentMode, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Profile Gradient Header with Photo & Major badge
                ProfileHeader(
                  name: displayName,
                  location: locationText,
                  major: academicText,
                  imageAsset: avatarUrl,
                  onShare: _handleShareProfile,
                  onSettings: () => showProfileSettingsSheet(context),
                  onChangeImage: _handleAvatarChange,
                  onEdit: _showEditConfirmationDialog,
                  isEditing: _isEditing,
                ),

                if (_isEditing) _buildEditingModeBanner(),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 36),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Academic & Major (Crucial for Recommendations)
                    _buildSectionCard(
                      title: 'Education & Academic Major',
                      icon: Icons.school_rounded,
                      iconColor: const Color(0xFF2B59FF),
                      subtitle: _isEditing
                          ? 'Update academic information for matching.'
                          : 'Official university and credential records.',
                      children: _isEditing
                          ? [
                              SoftTextField(
                                label: 'University / Institute',
                                controller: _universityController,
                                enabled: true,
                                hintText: 'e.g. CamTech',
                                validator: (v) =>
                                    validateRequired(v, 'your university'),
                              ),
                              const SizedBox(height: 16),
                              SoftTextField(
                                label: 'Major / Field of Study',
                                controller: _majorController,
                                enabled: true,
                                hintText: 'e.g. Computer Science',
                                validator: (v) =>
                                    validateRequired(v, 'your major'),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: SoftTextField(
                                      label: 'Degree & Year',
                                      controller: _degreeLevelController,
                                      enabled: true,
                                      hintText: "e.g. Bachelor's Degree",
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
                                      enabled: true,
                                      hintText: 'e.g. 3.75',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SoftTextField(
                                label: 'Expected Graduation',
                                controller: _gradYearController,
                                enabled: true,
                                hintText: 'e.g. 2026',
                              ),
                            ]
                          : [
                              _buildInfoRow(
                                icon: Icons.account_balance_rounded,
                                label: 'University / Institute',
                                value: _universityController.text,
                              ),
                              const Divider(height: 1),
                              _buildInfoRow(
                                icon: Icons.school_rounded,
                                label: 'Major / Field of Study',
                                value: _majorController.text,
                              ),
                              const Divider(height: 1),
                              _buildInfoRow(
                                icon: Icons.workspace_premium_rounded,
                                label: 'Degree & Level',
                                value: _degreeLevelController.text,
                              ),
                              const Divider(height: 1),
                              _buildInfoRow(
                                icon: Icons.grade_rounded,
                                label: 'GPA',
                                value: _gpaController.text,
                              ),
                              const Divider(height: 1),
                              _buildInfoRow(
                                icon: Icons.event_available_rounded,
                                label: 'Expected Graduation',
                                value: _gradYearController.text,
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
                                deleteIcon: _isEditing
                                    ? Icon(Icons.close, size: 14, color: AppColors.hintText)
                                    : null,
                                onDeleted: _isEditing
                                    ? () => setState(() => _skills.remove(skill))
                                    : null,
                                side: BorderSide(color: AppColors.cardBorder),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              );
                            }),
                            if (_isEditing)
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
                      subtitle: _isEditing
                          ? 'Recruiter contact details.'
                          : 'Verified contact credentials.',
                      children: _isEditing
                          ? [
                              SoftTextField(
                                label: 'Fullname',
                                controller: _fullNameController,
                                enabled: true,
                                validator: validateFullName,
                              ),
                              const SizedBox(height: 16),
                              SoftTextField(
                                label: 'Date of birth',
                                controller: _birthDateController,
                                enabled: true,
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
                                enabled: true,
                                onChanged: (String value) =>
                                    setState(() => _gender = value),
                              ),
                              const SizedBox(height: 16),
                              SoftTextField(
                                label: 'Email address',
                                controller: _emailController,
                                enabled: false,
                                hintText: 'student@example.com',
                                helperText:
                                    'Bound to your verified login account (cannot be changed)',
                                keyboardType: TextInputType.emailAddress,
                                validator: validateEmail,
                              ),
                              const SizedBox(height: 16),
                              ProfilePhoneField(
                                countryCode: _countryCode,
                                controller: _phoneController,
                                enabled: true,
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
                                enabled: true,
                                hintText: 'e.g. Phnom Penh, Cambodia',
                                validator: (String? value) =>
                                    validateRequired(value, 'your location'),
                              ),
                            ]
                          : [
                              _buildInfoRow(
                                icon: Icons.badge_outlined,
                                label: 'Full Legal Name',
                                value: _fullNameController.text,
                              ),
                              const Divider(height: 1),
                              _buildInfoRow(
                                icon: Icons.cake_outlined,
                                label: 'Date of Birth',
                                value: _birthDateController.text,
                              ),
                              const Divider(height: 1),
                              _buildInfoRow(
                                icon: Icons.wc_rounded,
                                label: 'Gender',
                                value: _gender,
                              ),
                              const Divider(height: 1),
                              _buildInfoRow(
                                icon: Icons.email_outlined,
                                label: 'Email Address',
                                value: _emailController.text,
                              ),
                              const Divider(height: 1),
                              _buildInfoRow(
                                icon: Icons.phone_outlined,
                                label: 'Phone Number',
                                value: _phoneController.text.trim().isNotEmpty
                                    ? '$_countryCode ${_phoneController.text.trim()}'
                                    : '',
                              ),
                              const Divider(height: 1),
                              _buildInfoRow(
                                icon: Icons.location_on_outlined,
                                label: 'Location',
                                value: _locationController.text,
                              ),
                            ],
                    ),

                    const SizedBox(height: 28),

                    // Save / Edit / Logout Actions
                    if (!_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => showLogoutSheet(context),
                              icon: const Icon(
                                Icons.logout_rounded,
                                size: 16,
                                color: AppColors.danger,
                              ),
                              label: Text(
                                'Log Out',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.danger,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                  color: AppColors.danger.withValues(alpha: 0.4),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () => _startEditing(scrollToTop: true),
                              icon: const Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Edit Profile',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _cancelEditing,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: AppColors.cardBorder),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'CANCEL',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.heading,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: WideButton(
                              text: _isSaving ? 'SAVING PROFILE...' : 'SAVE CHANGES',
                              onPressed: _isSaving ? () {} : _handleSave,
                            ),
                          ),
                        ],
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

  Widget _buildEditingModeBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 16, 18, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B),
          width: 1.5,
        ),
        boxShadow: softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: Color(0xFFF59E0B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editing Mode Active',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
                Text(
                  'Verified account email cannot be changed',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.hintText,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _cancelEditing,
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    final bool hasValue = value.trim().isNotEmpty;
    final Color effectiveColor = iconColor ?? AppColors.primaryBlue;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: effectiveColor.withValues(alpha: AppColors.isDark ? 0.35 : 0.22),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.hintText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasValue ? value.trim() : 'Not provided',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasValue
                        ? AppColors.heading
                        : AppColors.hintText.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                  color: iconColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: AppColors.isDark ? 0.35 : 0.22),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
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
                      _cvFileName ?? 'No CV attached yet',
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
                      _cvFileName != null
                          ? '${_cvFileSize ?? ""} • Updated ${_cvLastUpdated ?? ""}'
                          : 'Tap Replace CV to upload your PDF resume',
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
      initialDate: _selectedDob ?? DateTime(2003, 10, 15),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _selectedDob = picked;
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

  Future<void> _handleSave() async {
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

    setState(() => _isSaving = true);

    final nameParts = _fullNameController.text.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : firstName;

    final Map<String, dynamic> body = {
      'firstName': firstName,
      'lastName': lastName,
      'dob': (_selectedDob ?? DateTime(2003, 10, 15)).toIso8601String(),
      'gender': _gender.toUpperCase(),
      'currentAddress': _locationController.text.trim(),
      'description': '${_majorController.text.trim()} student at ${_universityController.text.trim()}',
      'phoneNumber': _phoneController.text.trim(),
    };

    try {
      if (_backendProfile != null) {
        _backendProfile = await StudentRepository.updateProfile(body);
      } else {
        _backendProfile = await StudentRepository.createProfile(body);
      }
      _showMessage('Profile saved to database successfully!');
    } catch (_) {
      _showMessage('Profile updated locally.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });
      }
    }
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
      _cvFileName = pickedName;
      _cvFileSize = _formatFileSize(bytes);
      _cvLastUpdated = _formatShortDate(DateTime.now());
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
    if (_cvFileName == null) {
      _showMessage('No CV attached yet. Please tap Replace CV to select a PDF.');
      return;
    }

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
                row('File name', _cvFileName ?? 'None'),
                row('Size', _cvFileSize ?? '0 KB'),
                row('Last updated', _cvLastUpdated ?? 'Never'),
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
