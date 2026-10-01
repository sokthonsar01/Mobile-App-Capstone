import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/app_colors.dart';
import '../../data/resume_model.dart';
import '../../viewmodel/cv_viewmodel.dart';

/// Clean document preview presentation for PDF and image CVs.
class CvPaperPreview extends StatelessWidget {
  final ResumeItem? resume;
  final CvViewModel vm;

  const CvPaperPreview({super.key, required this.resume, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (resume?.isImage == true) {
      if (vm.localPdfBytes != null) {
        return Image.memory(vm.localPdfBytes!, fit: BoxFit.contain);
      }
      if (resume?.fileUrl != null && resume!.fileUrl.startsWith('http')) {
        return Image.network(
          resume!.fileUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _buildDocumentCard(context),
        );
      }
    }

    return _buildDocumentCard(context);
  }

  Widget _buildDocumentCard(BuildContext context) {
    final title = resume?.displayName ?? 'Resume.pdf';
    final size = resume?.formattedSize ?? 'PDF Document';
    final url = resume?.fileUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFE11D48).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: Color(0xFFE11D48),
              size: 36,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            size,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.bodyText,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                const SizedBox(width: 6),
                Text(
                  'Cloud Synced (resumes)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (url != null && url.startsWith('http'))
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () => _openDocument(url),
                icon: const Icon(Icons.visibility_rounded, size: 17),
                label: Text(
                  'View Document',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openDocument(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  }
}
