import 'package:flutter/foundation.dart';
import '../data/company_model.dart';
import '../data/company_repository.dart';

/// ViewModel managing company profile fetching and presentation state.
class CompanyViewModel extends ChangeNotifier {
  Company? _company;
  bool _isLoading = false;
  String? _errorMessage;

  Company? get company => _company;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Sets initial fallback company details before network sync
  void setInitialCompany(Company fallback) {
    _company = fallback;
    notifyListeners();
  }

  /// Loads full company details from the NestJS backend by ID or name search
  Future<void> loadCompany({String? companyId, String? companyName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (companyId != null && companyId.trim().isNotEmpty) {
        _company = await CompanyRepository.getCompanyById(companyId.trim());
      } else if (companyName != null && companyName.trim().isNotEmpty) {
        final results = await CompanyRepository.getCompanies(search: companyName.trim());
        if (results.isNotEmpty) {
          _company = results.first;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
