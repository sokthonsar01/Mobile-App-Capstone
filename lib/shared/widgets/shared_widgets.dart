import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';

/// Small pieces used by more than one screen.

// ---------------------------------------------------------------------------
// 1. Soft white text field (profile + password screens)
// ---------------------------------------------------------------------------

/// A white box with a soft shadow and no visible border.
///
/// The auth screens use a different field (`AuthTextField`) that has a gray
/// border, because that is what the auth mockups show. Two styles exist
/// because the designer drew two styles. See the notes file.
class SoftTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final bool readOnly;
  final TextInputType keyboardType;

  /// Optional icon on the right, for example the calendar icon.
  final Widget? suffix;

  /// What happens when the user taps the box. Used by the date field.
  final VoidCallback? onTap;

  /// The check that runs when the user presses the button.
  /// null result = OK, a String = the red error message.
  final String? Function(String?)? validator;

  const SoftTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.onTap,
    this.validator,
  });

  @override
  State<SoftTextField> createState() => _SoftTextFieldState();
}

class _SoftTextFieldState extends State<SoftTextField> {
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
          child: TextFormField(
            controller: widget.controller,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            obscureText: widget.isPassword && _isHidden,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: AppColors.heading,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              errorStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.danger,
              ),
              errorMaxLines: 2,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _isHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.bodyText,
                        size: 22,
                      ),
                      onPressed: () =>
                          setState(() => _isHidden = !_isHidden),
                    )
                  : widget.suffix,
            ),
          ),
        ),
      ],
    );
  }
}

/// The soft gray shadow used on white cards and fields.
/// One list, so every card looks the same.
final List<BoxShadow> softShadow = [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.06),
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

// ---------------------------------------------------------------------------
// 2. Placeholder avatar (a colored circle with initials)
// ---------------------------------------------------------------------------

/// Shows the first letters of a name inside a colored circle.
///
/// We do NOT use the celebrity photos and company logos from the mockups.
/// Those pictures belong to other people and we are not allowed to ship them.
/// When the backend sends a real photo URL, swap this for Image.network.
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;

  /// true = square with rounded corners (used for company logos).
  final bool isSquare;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.isSquare = false,
  });

  /// "Taylor Swift" -> "TS".  "Cellcard" -> "C".
  String get _initials {
    final List<String> words =
        name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  /// Picks a color from the name so the same person always gets
  /// the same color. It is not random.
  Color get _background {
    const List<Color> palette = [
      Color(0xFF3B66FF),
      Color(0xFF7C4DFF),
      Color(0xFFEC407A),
      Color(0xFF26A69A),
      Color(0xFFFF9800),
      Color(0xFF5C6BC0),
    ];
    return palette[name.length % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _background,
        shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isSquare ? BorderRadius.circular(10) : null,
      ),
      child: Text(
        _initials,
        style: GoogleFonts.plusJakartaSans(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Bottom navigation bar
// ---------------------------------------------------------------------------

/// The bar at the bottom of the Messages and Saved screens.
///
/// TODO(team): the home screen owner may build their own bar.
/// If they do, delete this widget and use theirs instead.
/// It is on purpose in `shared/` so only one version survives.
class AppBottomNav extends StatelessWidget {
  /// Which icon is blue. 0 = home, 1 = explore, 3 = chat, 4 = saved.
  final int currentIndex;

  /// Called with the index the user tapped.
  final void Function(int index) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(Icons.home_outlined, 0),
          _navIcon(Icons.workspaces_outlined, 1),
          _centerButton(),
          _navIcon(Icons.chat_bubble_outline, 3),
          _navIcon(Icons.bookmark_border, 4),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    return IconButton(
      onPressed: () => onTap(index),
      icon: Icon(
        icon,
        size: 26,
        // The selected icon is blue, the others are dark gray.
        color: currentIndex == index ? AppColors.primaryBlue : Colors.black54,
      ),
    );
  }

  Widget _centerButton() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.primaryBlue,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Blue filled button used outside the auth screens
// ---------------------------------------------------------------------------

class WideButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  /// Pass a different color for the red CANCEL button.
  final Color color;

  const WideButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
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
