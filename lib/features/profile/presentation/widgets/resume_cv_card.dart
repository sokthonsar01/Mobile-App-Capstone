import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/app_colors.dart';
import '../../viewmodel/cv_viewmodel.dart';
import '../screens/cv_preview_screen.dart';

/// Reusable CV / Resume card widget adhering to MVVM and project standards.
class ResumeCvCard extends StatefulWidget {
  const ResumeCvCard({super.key});

  @override
  State<ResumeCvCard> createState() => _ResumeCvCardState();
}

class _ResumeCvCardState extends State<ResumeCvCard> {
  final CvViewModel _vm = CvViewModel.instance;

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onStateChange);
    if (!_vm.hasResume) _vm.loadMyResume();
  }

  @override
  void dispose() {
    _vm.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (!mounted) return;
    if (_vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_vm.errorMessage!), backgroundColor: AppColors.danger),
      );
      _vm.clearMessages();
    } else if (_vm.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_vm.successMessage!), backgroundColor: AppColors.online),
      );
      _vm.clearMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final resume = _vm.currentResume;
        final name = resume?.displayName ?? 'No CV uploaded yet';
        final size = resume?.formattedSize ?? 'Tap Replace CV to upload PDF';

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
              _buildInfoRow(name, size),
              const SizedBox(height: 12),
              _buildActionsRow(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String name, String size) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE11D48),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
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
                size,
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
    );
  }

  Widget _buildActionsRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CvPreviewScreen()),
            ),
            icon: const Icon(Icons.visibility_outlined, size: 16),
            label: Text(
              'Preview CV',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE11D48),
              side: const BorderSide(color: Color(0xFFFDA4AF)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _vm.isUploading ? null : () => _vm.pickAndUploadCv(),
            icon: _vm.isUploading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.upload_file_rounded, size: 16),
            label: Text(
              _vm.isUploading ? 'Uploading...' : 'Replace CV',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}
