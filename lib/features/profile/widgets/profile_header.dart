import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';

/// Top gradient header for the profile screen, displaying user avatar,
/// name, location, and action buttons.
class ProfileHeader extends StatelessWidget {
  final String name;
  final String location;
  final String? major;
  final String? university;
  final String? imageAsset;
  final VoidCallback onShare;
  final VoidCallback onSettings;
  final VoidCallback onChangeImage;
  final VoidCallback? onEdit;
  final bool isEditing;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.location,
    this.major,
    this.university,
    this.imageAsset,
    required this.onShare,
    required this.onSettings,
    required this.onChangeImage,
    this.onEdit,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    )
                  else
                    const SizedBox(width: 44),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onShare,
                        icon: const Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      IconButton(
                        onPressed: onSettings,
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  // Profile Photo with white border and edit badge
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InitialsAvatar(
                          name: name,
                          size: 68,
                          imageAsset: imageAsset,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: onChangeImage,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Name, Major & Location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (major != null)
                          Text(
                            major!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              location,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Match Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Profile active • Ready for Internship Placement',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Facebook-style Profile Actions
              if (!isEditing && onEdit != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: AppColors.headerBlueDark,
                        ),
                        label: Text(
                          'Edit Profile',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.headerBlueDark,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.headerBlueDark,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: onSettings,
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        tooltip: 'Profile Options',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
