import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renders a branded company logo container matching the dashboard mockup.
class CompanyLogoWidget extends StatelessWidget {
  final String logoKey;
  final String companyName;
  final Color brandColor;
  final double size;

  const CompanyLogoWidget({
    super.key,
    required this.logoKey,
    required this.companyName,
    required this.brandColor,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Center(
        child: _buildLogoContent(),
      ),
    );
  }

  Widget _buildLogoContent() {
    switch (logoKey) {
      case 'chip_mong':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE91E63),
                  width: 2.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.all_inclusive,
                  color: Color(0xFFE91E63),
                  size: 16,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'CHIP MONG',
              maxLines: 1,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 6,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.2,
              ),
            ),
          ],
        );

      case 'canadia':
        return Container(
          width: size - 8,
          height: size - 8,
          decoration: BoxDecoration(
            color: const Color(0xFFC62828),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD54F),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFFD54F),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'CANADIA BANK',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );

      case 'cellcard':
        return Container(
          width: size - 8,
          height: size - 8,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9800),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_tethering,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(height: 1),
              Text(
                'cellcard',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'ROYAL GROUP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 4.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );

      case 'aba':
        return Container(
          width: size - 8,
          height: size - 8,
          decoration: BoxDecoration(
            color: const Color(0xFF003D6B),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'ABA',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        );

      case 'smart':
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Smart',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF009639),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.flare_rounded,
                color: Color(0xFFE91E63),
                size: 13,
              ),
            ],
          ),
        );

      case 'hanuman':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.domain_rounded,
              color: Color(0xFF1565C0),
              size: 24,
            ),
            const SizedBox(height: 1),
            Text(
              'HANUMAN',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 6,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1565C0),
              ),
            ),
            Text(
              'ESTATE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 4.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE65100),
              ),
            ),
          ],
        );

      case 'meoys':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.military_tech_rounded,
              color: Color(0xFFF57F17),
              size: 26,
            ),
            const SizedBox(height: 1),
            Text(
              'MEOYS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 6,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF8D6E63),
              ),
            ),
          ],
        );

      default:
        return Container(
          width: size - 8,
          height: size - 8,
          decoration: BoxDecoration(
            color: brandColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              companyName.isNotEmpty ? companyName[0].toUpperCase() : '?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: brandColor,
              ),
            ),
          ),
        );
    }
  }
}
