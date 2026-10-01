import 'package:flutter/material.dart';

import '../data/internship_model.dart';
import '../data/internship_repository.dart';

/// ViewModel managing home internship opportunities, reactive filtering,
/// and live NestJS backend synchronization following the MVVM architecture.
class InternshipsViewModel extends ChangeNotifier {
  static final InternshipsViewModel instance = InternshipsViewModel._internal();

  InternshipsViewModel._internal();

  List<InternshipOpportunity> _internships = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedCategory = 'All';
  String _searchQuery = '';
  String? _selectedLocation;
  bool _paymentOnly = false;

  List<InternshipOpportunity> get internships =>
      List.unmodifiable(_internships);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String? get selectedLocation => _selectedLocation;
  bool get paymentOnly => _paymentOnly;

  /// Returns internships filtered by category, search query, location, and payment status.
  List<InternshipOpportunity> get filteredInternships {
    return _internships.where((internship) {
      if (_selectedCategory != 'All' &&
          internship.category.toLowerCase() !=
              _selectedCategory.toLowerCase()) {
        return false;
      }

      if (_selectedLocation != null &&
          _selectedLocation!.isNotEmpty &&
          !internship.location
              .toLowerCase()
              .contains(_selectedLocation!.toLowerCase())) {
        return false;
      }

      if (_paymentOnly &&
          !internship.paymentStatus.toLowerCase().contains('paid')) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesRole = internship.role.toLowerCase().contains(query);
        final matchesCompany =
            internship.company.toLowerCase().contains(query);
        final matchesCategory =
            internship.category.toLowerCase().contains(query);
        final matchesLocation =
            internship.location.toLowerCase().contains(query);
        if (!matchesRole &&
            !matchesCompany &&
            !matchesCategory &&
            !matchesLocation) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Sets internships directly (useful for tests and offline fallback).
  void setInternships(List<InternshipOpportunity> items) {
    _internships = List.from(items);
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Explicitly controls loading state (useful for tests and optimistic flows).
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Loads internships from the backend API.
  Future<void> loadInternships({bool force = false}) async {
    if (_internships.isNotEmpty && !force) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await InternshipRepository.getInternships();
      _internships = items;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  void setSearch(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setLocation(String? location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void setPaymentOnly(bool paymentOnly) {
    _paymentOnly = paymentOnly;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _selectedLocation = null;
    _paymentOnly = false;
    notifyListeners();
  }
}
