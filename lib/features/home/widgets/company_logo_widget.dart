import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renders a branded company logo container loading local asset PNGs or network fallbacks.
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

  String get _logoAssetPath {
    switch (logoKey) {
      case 'chip_mong':
        return 'assets/images/logos/Chigmong logo.png';
      case 'canadia':
        return 'assets/images/logos/Canada bank logo.png';
      case 'cellcard':
        return 'assets/images/logos/Cellcard logo.png';
      case 'aba':
        return 'assets/images/logos/ABA Logo.png';
      case 'smart':
        return 'assets/images/logos/smart logo.png';
      case 'hanuman':
        return 'assets/images/logos/Hanuman beer logo.png';
      case 'meoys':
        return 'assets/images/logos/Moeys Logo.png';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _logoAssetPath;

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
        child: assetPath.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  assetPath,
                  width: size - 8,
                  height: size - 8,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _buildLogoContent(),
                  ),
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: _buildLogoContent(),
              ),
      ),
    );
  }

  Widget _buildLogoContent() {
    switch (logoKey) {
      case 'chip_mong':
        return Image.network(
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZBznQbTGb-NmhCY84hvAJEH2Cdyl3T_Rf3fKnB2anXy4Yt35DgWN9pFKF&s=10',
          errorBuilder: (_, _, _) => const Icon(Icons.business_rounded),
        );

      case 'canadia':
        return Image.network(
          'https://hrincjobs-pro.s3.amazonaws.com/media/public/filer_public/e9/72/e97240fd-c1ba-49fb-9f5e-59f20bc92212/canadiaa.jpg',
          errorBuilder: (_, _, _) => const Icon(Icons.account_balance_rounded),
        );

      case 'cellcard':
        return Image.network(
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ90FPfI8T4ifz4LNsO-c2W0dsLV6l8Pdw-LcJQ915F-g&s=10',
          errorBuilder: (_, _, _) => const Icon(Icons.wifi_rounded),
        );

      case 'aba':
        return Image.network(
          'https://play-lh.googleusercontent.com/O7xMXY5ehCEVwpR0MlKYQOK5QJ1oFIw4EoXQqyt_vgDKT3Uvn1g8FIz_fNDDhWH4Zbdclp54WhRMnI8vzyE9OeU=w240-h480-rw',
          errorBuilder: (_, _, _) => const Icon(Icons.account_balance_rounded),
        );

      case 'smart':
        return Image.network(
          'https://images.seeklogo.com/logo-png/30/2/smart-axiata-logo-png_seeklogo-309284.png',
          errorBuilder: (_, _, _) => const Icon(Icons.cell_tower_rounded),
        );

      case 'hanuman':
        return Image.network(
          'https://images.seeklogo.com/logo-png/61/1/hanuman-beer-logo-png_seeklogo-617034.png',
          errorBuilder: (_, _, _) => const Icon(Icons.sports_bar_rounded),
        );

      case 'meoys':
        return Image.network(
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShOXD4X1UoMvxK3VGJWSw7HG--7Vg4WFCxy5edJloa3w&s',
          errorBuilder: (_, _, _) => const Icon(Icons.school_rounded),
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
