import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/app_colors.dart';
import '../../../home/data/application_tracker_store.dart';
import '../../../home/data/internship_model.dart';
import '../../../home/presentation/application_submitted_screen.dart';
import '../../data/company_model.dart';
import '../../data/company_repository.dart';
import '../widgets/company_contact_card.dart';
import '../widgets/company_details_card.dart';
import '../widgets/company_profile_header.dart';

/// Screen displaying the full company profile fetched from the NestJS backend.
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
  late Company _company;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _company = widget.company ?? _buildInitialFallback();
    _fetchLiveCompany();
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

  Future<void> _fetchLiveCompany() async {
    final id = widget.companyId ?? widget.internship?.companyId;
    setState(() => _isLoading = true);
    try {
      if (id != null && id.isNotEmpty) {
        final fetched = await CompanyRepository.getCompanyById(id);
        if (mounted) setState(() => _company = fetched);
      } else {
        final results = await CompanyRepository.getCompanies(
          search: widget.internship?.company ?? widget.companyName,
        );
        if (mounted && results.isNotEmpty) {
          setState(() => _company = results.first);
        }
      }
    } catch (_) {
      // Fallback seamlessly to initial fallback
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
          _company.name,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.heading,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLiveCompany,
        color: AppColors.primaryBlue,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.primaryBlue,
                ),
              ),
            CompanyProfileHeader(
              company: _company,
              logoKey: widget.internship?.logoKey ?? 'default',
              brandColor: widget.internship?.brandColor ?? AppColors.primaryBlue,
            ),
            const SizedBox(height: 24),
            CompanyDetailsCard(company: _company),
            const SizedBox(height: 18),
            CompanyContactCard(company: _company),
            const SizedBox(height: 28),
            if (widget.internship != null) _buildApplyButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        ApplicationTrackerStore.instance
            .applyForInternship(widget.internship!);
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
