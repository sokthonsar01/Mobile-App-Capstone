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
      child: Center(child: _buildLogoContent()),
    );
  }

  Widget _buildLogoContent() {
    switch (logoKey) {
      case 'chip_mong':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZBznQbTGb-NmhCY84hvAJEH2Cdyl3T_Rf3fKnB2anXy4Yt35DgWN9pFKF&s=10',
            ),
          ],
        );

      case 'canadia':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'https://hrincjobs-pro.s3.amazonaws.com/media/public/filer_public/e9/72/e97240fd-c1ba-49fb-9f5e-59f20bc92212/canadiaa.jpg',
            ),
          ],
        );

      case 'cellcard':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ90FPfI8T4ifz4LNsO-c2W0dsLV6l8Pdw-LcJQ915F-g&s=10'),
          ],
        );

      case 'aba':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network('https://play-lh.googleusercontent.com/O7xMXY5ehCEVwpR0MlKYQOK5QJ1oFIw4EoXQqyt_vgDKT3Uvn1g8FIz_fNDDhWH4Zbdclp54WhRMnI8vzyE9OeU=w240-h480-rw'),
          ],
        );

      case 'smart':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network('https://images.seeklogo.com/logo-png/30/2/smart-axiata-logo-png_seeklogo-309284.png'),
          ],
        );

      case 'hanuman':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network('https://images.seeklogo.com/logo-png/61/1/hanuman-beer-logo-png_seeklogo-617034.png'),
          ],
        );

      case 'meoys':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShOXD4X1UoMvxK3VGJWSw7HG--7Vg4WFCxy5edJloa3w&s'),
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
