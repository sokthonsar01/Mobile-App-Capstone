import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/app_colors.dart';
import '../../viewmodel/cv_viewmodel.dart';

/// Screen allowing the student to inspect and verify their uploaded CV document.
class CvPreviewScreen extends StatelessWidget {
  const CvPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: CvViewModel.instance,
          builder: (context, _) {
            final vm = CvViewModel.instance;
            final resume = vm.currentResume;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _buildHeaderCard(context, resume?.displayName ?? 'Resume.pdf'),
                const SizedBox(height: 16),
                _buildMetadataCard(resume),
                const SizedBox(height: 20),
                _buildDocumentPreviewCard(context, resume?.fileUrl),
                const SizedBox(height: 24),
                _buildActionButtons(context),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'CV Document Preview',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.heading,
        ),
      ),
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.heading, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, String fileName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE11D48),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE11D48).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Verified Cloud PDF Document',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard(dynamic resume) {
    final sizeText = resume?.formattedSize ?? 'PDF Document';
    final url = resume?.fileUrl ?? 'Not synced yet';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _buildInfoRow('File Format', 'Portable Document Format (.pdf)'),
          const Divider(height: 20),
          _buildInfoRow('Document Size', sizeText),
          const Divider(height: 20),
          _buildInfoRow('Cloud Status', 'Stored in Supabase (resumes)'),
          const Divider(height: 20),
          _buildInfoRow('Public URL', url, isLink: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.bodyText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: isLink ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isLink ? AppColors.primaryBlue : AppColors.heading,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentPreviewCard(BuildContext context, String? fileUrl) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: AppColors.hintText.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(
            'Ready for 1-Tap Applications',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Employers receive this verified resume file directly when you submit your internship applications.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.bodyText,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final vm = CvViewModel.instance;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: vm.isUploading ? null : () => vm.pickAndUploadCv(),
        icon: vm.isUploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.upload_file_rounded, size: 18),
        label: Text(
          vm.isUploading ? 'Uploading to Supabase...' : 'Replace with New CV',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE11D48),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
