import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/app_colors.dart';
import '../../data/resume_model.dart';
import '../../viewmodel/cv_viewmodel.dart';
import '../widgets/cv_paper_preview.dart';

/// Overlay displaying only the CV picture/document and a Change CV action.
/// Clicking outside the document and button dismisses the overlay.
class CvPreviewScreen extends StatelessWidget {
  const CvPreviewScreen({super.key});

  /// Convenient helper to display the overlay from anywhere.
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      barrierDismissible: true,
      builder: (_) => const CvPreviewScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      elevation: 0,
      child: ListenableBuilder(
        listenable: CvViewModel.instance,
        builder: (context, _) {
          final vm = CvViewModel.instance;
          final resume = vm.currentResume;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDocumentCard(context, resume, vm),
              const SizedBox(height: 14),
              _buildChangeButton(context, vm),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    ResumeItem? resume,
    CvViewModel vm,
  ) {
    final screenH = MediaQuery.of(context).size.height;
    final maxH = (screenH * 0.6).clamp(300.0, 460.0);

    return Container(
      constraints: BoxConstraints(maxWidth: 360, maxHeight: maxH),
      decoration: BoxDecoration(
        color: AppColors.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          CvPaperPreview(resume: resume, vm: vm),
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, size: 22),
              color: AppColors.bodyText,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeButton(BuildContext context, CvViewModel vm) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: vm.isUploading ? null : () => vm.pickAndUploadCv(),
          icon: vm.isUploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.upload_file_rounded, size: 18),
          label: Text(
            vm.isUploading ? 'Uploading...' : 'Change CV',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
