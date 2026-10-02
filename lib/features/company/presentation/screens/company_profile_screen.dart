import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/app_colors.dart';
import '../../../applications/data/application_tracker_store.dart';
import '../../../../shared/page_transitions.dart';
import '../../../applications/presentation/application_submitted_screen.dart';
import '../../../home/data/internship_model.dart';
import '../../data/company_model.dart';
import '../../viewmodel/company_viewmodel.dart';
import '../widgets/company_contact_card.dart';
import '../widgets/company_details_card.dart';
import '../widgets/company_profile_header.dart';

/// Screen displaying the full company profile using MVVM architecture.
class CompanyProfileScreen extends StatefulWidget {
  final String? companyId;
  final Company? company;
  final InternshipOpportunity? internship;
  final String companyName;

  const CompanyProfileScreen({
    super.key,
    this.companyId,
    this.company,
    this.internship,
    this.companyName = 'Company',
  });

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  late final CompanyViewModel _vm;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _vm = CompanyViewModel();
    _vm.setInitialCompany(widget.company ?? _buildInitialFallback());
    _loadData();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Company _buildInitialFallback() {
    final effectiveName = widget.internship?.company ?? widget.companyName;
    return Company(
      id: widget.companyId ?? widget.internship?.companyId ?? '',
      userId: '',
      name: effectiveName,
      contact: '',
      industry: widget.internship?.category ?? 'General',
    );
  }

  Future<void> _loadData() {
    return _vm.loadCompany(
      companyId: widget.companyId ?? widget.internship?.companyId,
      companyName: widget.internship?.company ?? widget.companyName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final company = _vm.company ?? _buildInitialFallback();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(company.name),
          body: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primaryBlue,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                if (_vm.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                CompanyProfileHeader(
                  company: company,
                  logoKey: widget.internship?.logoKey ?? 'default',
                  brandColor:
                      widget.internship?.brandColor ?? AppColors.primaryBlue,
                ),
                const SizedBox(height: 24),
                CompanyDetailsCard(company: company),
                const SizedBox(height: 18),
                CompanyContactCard(company: company),
                const SizedBox(height: 28),
                if (widget.internship != null) _buildApplyButton(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(String title) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.heading,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.heading,
        ),
      ),
      centerTitle: true,
    );
  }

  Future<void> _handleApply() async {
    if (_isSubmitting || widget.internship == null) return;
    setState(() => _isSubmitting = true);

    final startTime = DateTime.now();
    final error = await ApplicationTrackerStore.instance
        .applyToInternship(item: widget.internship!);
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed.inMilliseconds < 650) {
      await Future.delayed(
        Duration(milliseconds: 650 - elapsed.inMilliseconds),
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      createSmoothPageRoute(
        page: ApplicationSubmittedScreen(
          internship: widget.internship!,
        ),
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    final item = widget.internship;
    final isAlreadyApplied = item != null &&
        ApplicationTrackerStore.instance.isAlreadyApplied(
          item.id,
          company: item.company,
          role: item.role,
        );

    return ElevatedButton(
      onPressed: _isSubmitting
          ? null
          : (isAlreadyApplied
              ? () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'You have already applied for this internship.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: const Color(0xFF64748B),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              : _handleApply),
      style: ElevatedButton.styleFrom(
        backgroundColor: isAlreadyApplied ? const Color(0xFF64748B) : AppColors.primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: _isSubmitting
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              isAlreadyApplied ? 'Already Applied' : 'Apply Now',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
