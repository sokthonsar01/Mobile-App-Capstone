/// Represents a student CV / Resume document.
class ResumeItem {
  final String id;
  final String studentId;
  final String fileUrl;
  final String? fileName;
  final int? fileSizeBytes;
  final DateTime? updatedAt;
  final bool isDefault;

  const ResumeItem({
    required this.id,
    required this.studentId,
    required this.fileUrl,
    this.fileName,
    this.fileSizeBytes,
    this.updatedAt,
    this.isDefault = true,
  });

  String get displayName {
    if (fileName != null && fileName!.isNotEmpty) {
      return fileName!;
    }
    // Extract file name from URL if possible
    try {
      final uri = Uri.parse(fileUrl);
      final segment = uri.pathSegments.last;
      if (segment.isNotEmpty) return segment;
    } catch (_) {}
    return 'Resume.pdf';
  }

  String get formattedSize {
    if (fileSizeBytes == null || fileSizeBytes == 0) return 'PDF Document';
    if (fileSizeBytes! >= 1024 * 1024) {
      return '${(fileSizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSizeBytes! / 1024).ceil()} KB';
  }

  factory ResumeItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic d) =>
        d != null ? DateTime.tryParse(d.toString()) : null;

    return ResumeItem(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString() ?? '',
      fileName: json['fileName']?.toString(),
      fileSizeBytes: json['fileSizeBytes'] is int
          ? json['fileSizeBytes'] as int
          : int.tryParse(json['fileSizeBytes']?.toString() ?? ''),
      updatedAt: parseDate(json['updatedAt']),
      isDefault: json['isDefault'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'fileUrl': fileUrl,
      if (fileName != null) 'fileName': fileName,
      if (fileSizeBytes != null) 'fileSizeBytes': fileSizeBytes,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'isDefault': isDefault,
    };
  }
}
