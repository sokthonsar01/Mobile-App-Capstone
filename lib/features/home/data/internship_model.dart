import 'package:flutter/material.dart';
import 'demo_internships.dart';
export 'demo_internships.dart';

/// One internship opportunity displayed in the home dashboard.
class InternshipOpportunity {
  final String id;
  final String? companyId;
  final String role;
  final String company;
  final String category;
  final String location;
  final String schedule;
  final String paymentStatus;
  final String deadline;
  final Color brandColor;
  final String logoKey;
  final String? logoUrl;
  final String description;
  final List<String> requirements;
  final String stipend;
  final bool isSaved;

  const InternshipOpportunity({
    required this.id,
    this.companyId,
    required this.role,
    required this.company,
    required this.category,
    required this.location,
    required this.schedule,
    required this.paymentStatus,
    required this.deadline,
    required this.brandColor,
    required this.logoKey,
    this.logoUrl,
    required this.description,
    required this.requirements,
    this.stipend = '\$200 - \$350 / month',
    this.isSaved = false,
  });

  factory InternshipOpportunity.fromJson(Map<String, dynamic> json) {
    final companyObj = json['company'] is Map ? json['company'] as Map<String, dynamic> : null;
    final companyName = companyObj?['name'] as String? ?? (json['company'] as String? ?? 'Company');

    List<String> requirementsList = [];
    if (json['requiredSkills'] is List) {
      requirementsList = (json['requiredSkills'] as List)
          .map((s) => s['skill']?['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    }
    if (requirementsList.isEmpty && json['requirements'] is String) {
      requirementsList = (json['requirements'] as String)
          .split('\n')
          .map((e) => e.trim().replaceFirst(RegExp(r'^[-•*]\s*'), ''))
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return InternshipOpportunity(
      id: json['id']?.toString() ?? '',
      role: json['title']?.toString() ?? json['role']?.toString() ?? '',
      company: companyName,
      companyId: json['companyId']?.toString() ?? companyObj?['id']?.toString(),
      category: json['category']?.toString() ?? 'Tech',
      location: json['location']?.toString() ?? '',
      schedule: json['type'] != null ? '${json['type']} Internship' : (json['schedule']?.toString() ?? 'Full-Time'),
      paymentStatus: (json['stipend'] != null && json['stipend'].toString().isNotEmpty) ? 'Payment Included' : 'Unpaid',
      deadline: json['deadline'] != null ? json['deadline'].toString().split('T').first : 'Open',
      brandColor: _resolveBrandColor(companyName),
      logoKey: _resolveLogoKey(companyName),
      logoUrl: companyObj?['logoUrl']?.toString() ?? json['logoUrl']?.toString(),
      description: json['description']?.toString() ?? '',
      requirements: requirementsList,
      stipend: json['stipend']?.toString() ?? 'Undisclosed',
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }

  static Color _resolveBrandColor(String companyName) {
    final lower = companyName.toLowerCase();
    if (lower.contains('chip mong')) return const Color(0xFFE91E63);
    if (lower.contains('canadia')) return const Color(0xFFC62828);
    if (lower.contains('cellcard')) return const Color(0xFFFF9800);
    if (lower.contains('aba')) return const Color(0xFF003D6B);
    if (lower.contains('smart')) return const Color(0xFF2E7D32);
    if (lower.contains('hanuman')) return const Color(0xFF1565C0);
    if (lower.contains('meoys')) return const Color(0xFFF57F17);
    return const Color(0xFF1E88E5);
  }

  static String _resolveLogoKey(String companyName) {
    final lower = companyName.toLowerCase();
    if (lower.contains('chip mong')) return 'chip_mong';
    if (lower.contains('canadia')) return 'canadia';
    if (lower.contains('cellcard')) return 'cellcard';
    if (lower.contains('aba')) return 'aba';
    if (lower.contains('smart')) return 'smart';
    if (lower.contains('hanuman')) return 'hanuman';
    if (lower.contains('meoys')) return 'meoys';
    return 'default';
  }

  /// Full display title like "Marketing Intern at Chip Mong"
  String get displayTitle => '$role at $company';

  /// Path to the company logo PNG image asset.
  String get logoAssetPath {
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return logoUrl!;
    }
    switch (logoKey) {
      case 'chip_mong':
        return 'assets/images/logos/Chigmong logo.png';
      case 'canadia':
        return 'assets/images/logos/Canada bank logo.png';
      case 'cellcard':
        return 'assets/images/logos/Cellcard logo.png';
      case 'aba':
        return 'assets/images/logos/ABA Logo.png';
      case 'smart':
        return 'assets/images/logos/smart logo.png';
      case 'hanuman':
        return 'assets/images/logos/Hanuman beer logo.png';
      case 'meoys':
        return 'assets/images/logos/Moeys Logo.png';
      default:
        return 'assets/images/main_logo.png';
    }
  }

  /// Path to the 750x350 card poster PNG image asset.
  String get posterAssetPath {
    switch (logoKey) {
      case 'chip_mong':
        return 'assets/images/posters/Chigmong card 750 x 350.png';
      case 'canadia':
        return 'assets/images/posters/Canada bank card 750 x 350.png';
      case 'cellcard':
        return 'assets/images/posters/Cellcard card 750 x 350.png';
      case 'aba':
        return 'assets/images/posters/aba card 750 x 350.png';
      case 'smart':
        return 'assets/images/posters/Smart card  750 x 350.png';
      case 'hanuman':
        return 'assets/images/posters/hanuman card 750 x 350.png';
      case 'meoys':
        return 'assets/images/posters/Moeys card 750 x 350.png';
      default:
        return '';
    }
  }

  /// Path to the 1280x480 wide banner poster PNG image asset.
  String get bannerPosterAssetPath {
    switch (logoKey) {
      case 'chip_mong':
        return 'assets/images/posters/Chipmong card 1280 x 480.png';
      case 'canadia':
        return 'assets/images/posters/Canada bank Card 1280 x 480.png';
      case 'cellcard':
        return 'assets/images/posters/Cellcard card 1280 x 480.png';
      case 'aba':
        return 'assets/images/posters/aba Card 1280 x 480.png';
      case 'smart':
        return 'assets/images/posters/smart card 1280 x 480.png';
      case 'hanuman':
        return 'assets/images/posters/Hanuman Card 1280 x 480 (2).png';
      case 'meoys':
        return 'assets/images/posters/Moeys card 1280 x 480.png';
      default:
        return '';
    }
  }

  InternshipOpportunity copyWith({
    String? id,
    String? companyId,
    String? role,
    String? company,
    String? category,
    String? location,
    String? schedule,
    String? paymentStatus,
    String? deadline,
    Color? brandColor,
    String? logoKey,
    String? logoUrl,
    String? description,
    List<String>? requirements,
    String? stipend,
    bool? isSaved,
  }) {
    return InternshipOpportunity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      role: role ?? this.role,
      company: company ?? this.company,
      category: category ?? this.category,
      location: location ?? this.location,
      schedule: schedule ?? this.schedule,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deadline: deadline ?? this.deadline,
      brandColor: brandColor ?? this.brandColor,
      logoKey: logoKey ?? this.logoKey,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      stipend: stipend ?? this.stipend,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

/// Helper to automatically find an internship opportunity by company name or keyword.
InternshipOpportunity? findInternshipByCompany(String companyName) {
  if (companyName.trim().isEmpty) return null;
  final clean = companyName.toLowerCase().trim();

  // 1. Exact company match
  for (final item in demoInternships) {
    if (item.company.toLowerCase().trim() == clean) {
      return item;
    }
  }

  // 2. Substring / contains match (e.g. 'Smart Axiata' -> 'Smart', 'Hanuman Estate' -> 'Hanuman', 'ABA Bank' -> 'ABA')
  for (final item in demoInternships) {
    final comp = item.company.toLowerCase().trim();
    if (clean.contains(comp) || comp.contains(clean)) {
      return item;
    }
  }

  // 3. Match against logoKey or aliases (including 'meoys' / 'moeys')
  for (final item in demoInternships) {
    final key = item.logoKey.replaceAll('_', '').toLowerCase();
    final simplified = clean.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (simplified.contains(key) || key.contains(simplified)) {
      return item;
    }
    if ((clean.contains('moeys') || clean.contains('meoys')) && item.logoKey == 'meoys') {
      return item;
    }
  }

  return null;
}
