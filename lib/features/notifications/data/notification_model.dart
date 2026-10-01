import 'package:flutter/material.dart';
import '../../home/data/internship_model.dart';
import '../../home/viewmodel/internships_viewmodel.dart';

/// Single notification model mapped to backend NestJS entity.
class AppNotification {
  final String id;
  final String companyName;
  final String title;
  final String body;
  final String timeAgo;
  final bool isUnread;
  final String? type;
  final String? internshipId;
  final String? logoKey;
  final Color? brandColor;
  final DateTime? createdAt;

  const AppNotification({
    this.id = '',
    required this.companyName,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isUnread = false,
    this.type,
    this.internshipId,
    this.logoKey,
    this.brandColor,
    this.createdAt,
  });

  /// Factory constructor to parse notification from backend NestJS API
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'].toString())
        : null;

    String formatTimeAgo(DateTime? dt) {
      if (dt == null) return 'Recently';
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    }

    String resolvedCompany = json['companyName']?.toString() ?? '';
    String? resolvedInternshipId = json['internshipId']?.toString();
    if (resolvedCompany.isEmpty &&
        json['internship'] != null &&
        json['internship'] is Map) {
      final intern = json['internship'] as Map;
      resolvedInternshipId ??= intern['id']?.toString();
      if (intern['company'] != null && intern['company'] is Map) {
        resolvedCompany = intern['company']['name']?.toString() ?? '';
      }
    }
    if (resolvedCompany.isEmpty) {
      resolvedCompany = 'Interna';
    }

    final readVal = json['isRead'] ?? json['read'] ?? false;
    final isUnread = readVal == false || readVal == 0;

    return AppNotification(
      id: json['id']?.toString() ?? '',
      companyName: resolvedCompany,
      title: json['title']?.toString() ?? 'Notification',
      body: json['message']?.toString() ?? json['body']?.toString() ?? '',
      timeAgo: formatTimeAgo(createdAt),
      isUnread: isUnread,
      type: json['type']?.toString(),
      internshipId: resolvedInternshipId,
      createdAt: createdAt,
    );
  }

  /// Factory constructor to automatically create a notification from an internship posting.
  factory AppNotification.fromInternship({
    required InternshipOpportunity internship,
    required String title,
    required String body,
    required String timeAgo,
    bool isUnread = false,
  }) {
    return AppNotification(
      companyName: internship.company,
      title: title,
      body: body,
      timeAgo: timeAgo,
      isUnread: isUnread,
      internshipId: internship.id,
      logoKey: internship.logoKey,
      brandColor: internship.brandColor,
    );
  }

  /// Resolves the matching internship opportunity automatically from the company that posted it.
  InternshipOpportunity? get resolvedInternship {
    if (internshipId != null && internshipId!.isNotEmpty) {
      try {
        return InternshipsViewModel.instance.internships
            .firstWhere((i) => i.id == internshipId);
      } catch (_) {}
    }
    return findInternshipByCompany(
        companyName, InternshipsViewModel.instance.internships);
  }

  /// Automatically retrieves the correct company logo key from the internship poster.
  String get effectiveLogoKey {
    if (logoKey != null && logoKey!.isNotEmpty) return logoKey!;
    final resolved = resolvedInternship?.logoKey;
    if (resolved != null && resolved.isNotEmpty) return resolved;
    return resolveLogoKeyFromName(companyName);
  }

  /// Normalizes company name to known brand logo asset keys.
  static String resolveLogoKeyFromName(String name) {
    final lower = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (lower.contains('chipmong')) return 'chip_mong';
    if (lower.contains('cellcard')) return 'cellcard';
    if (lower.contains('smart')) return 'smart';
    if (lower.contains('aba')) return 'aba';
    if (lower.contains('hanuman')) return 'hanuman';
    if (lower.contains('canadia')) return 'canadia';
    if (lower.contains('moeys') || lower.contains('meoys')) return 'meoys';
    return '';
  }

  /// Automatically retrieves the correct company brand color from the internship poster.
  Color get effectiveBrandColor {
    if (brandColor != null) return brandColor!;
    return resolvedInternship?.brandColor ?? const Color(0xFF1E3A8A);
  }

  AppNotification copyWith({
    String? id,
    String? companyName,
    String? title,
    String? body,
    String? timeAgo,
    bool? isUnread,
    String? type,
    String? internshipId,
    String? logoKey,
    Color? brandColor,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      title: title ?? this.title,
      body: body ?? this.body,
      timeAgo: timeAgo ?? this.timeAgo,
      isUnread: isUnread ?? this.isUnread,
      type: type ?? this.type,
      internshipId: internshipId ?? this.internshipId,
      logoKey: logoKey ?? this.logoKey,
      brandColor: brandColor ?? this.brandColor,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
