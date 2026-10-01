import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/app_colors.dart';
import '../../data/resume_model.dart';
import '../../viewmodel/cv_viewmodel.dart';

/// Paper-styled document visual representation for PDF and image CVs.
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
          errorBuilder: (_, _, _) => _buildPdfPaper(),
        );
      }
    }
    return _buildPdfPaper();
  }

  Widget _buildPdfPaper() {
    final title = resume?.displayName ?? 'Resume.pdf';
    final size = resume?.formattedSize ?? 'PDF Document';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                    Text(
                      size,
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.bodyText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 28),
            ],
          ),
          const Divider(height: 20),
          _buildSkeletonSection('EXPERIENCE'),
          const SizedBox(height: 12),
          _buildSkeletonSection('EDUCATION'),
          const SizedBox(height: 14),
          _buildAtsBadge(),
        ],
      ),
    );
  }

  Widget _buildSkeletonSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: AppColors.bodyText,
          ),
        ),
        const SizedBox(height: 6),
        Container(height: 7, width: double.infinity, color: AppColors.cardBorder),
        const SizedBox(height: 5),
        Container(height: 7, width: 180, color: AppColors.cardBorder.withValues(alpha: 0.6)),
      ],
    );
  }

  Widget _buildAtsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF10B981)),
          const SizedBox(width: 6),
          Text(
            'ATS Verified Document',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}
