import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/app_colors.dart';
import '../../../applications/data/application_tracker_store.dart';
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

  Widget _buildApplyButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        ApplicationTrackerStore.instance
            .applyToInternship(item: widget.internship!);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ApplicationSubmittedScreen(
              internship: widget.internship!,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: Text(
        'Apply Now',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
