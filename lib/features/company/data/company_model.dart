/// Model representing a company registered in the Interna platform.
class Company {
  final String id;
  final String userId;
  final String name;
  final String? logoUrl;
  final String? website;
  final String contact;
  final String industry;
  final String? description;
  final bool verified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int internshipCount;

  const Company({
    required this.id,
    required this.userId,
    required this.name,
    this.logoUrl,
    this.website,
    required this.contact,
    required this.industry,
    this.description,
    this.verified = false,
    this.createdAt,
    this.updatedAt,
    this.internshipCount = 0,
  });

  /// Factory constructor to parse NestJS Company entity JSON.
  factory Company.fromJson(Map<String, dynamic> json) {
    int parsedInternshipCount = 0;
    if (json['_count'] is Map && json['_count']['internships'] is int) {
      parsedInternshipCount = json['_count']['internships'] as int;
    } else if (json['internships'] is List) {
      parsedInternshipCount = (json['internships'] as List).length;
    }

    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      return DateTime.tryParse(date.toString());
    }

    return Company(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Company',
      logoUrl: json['logoUrl']?.toString(),
      website: json['website']?.toString(),
      contact: json['contact']?.toString() ?? '',
      industry: json['industry']?.toString() ?? 'General',
      description: json['description']?.toString(),
      verified: json['verified'] as bool? ?? false,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      internshipCount: parsedInternshipCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (website != null) 'website': website,
      'contact': contact,
      'industry': industry,
      if (description != null) 'description': description,
      'verified': verified,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
