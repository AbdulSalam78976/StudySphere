class ResourceModel {
  final String id;
  final String groupId;
  final String uploadedBy;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final String? category;
  final String? description;
  final int downloadCount;
  final double? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  ResourceModel({
    required this.id,
    required this.groupId,
    required this.uploadedBy,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    this.category,
    this.description,
    this.downloadCount = 0,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      uploadedBy: json['uploaded_by'] as String,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String,
      fileSize: json['file_size'] as int,
      category: json['category'] as String?,
      description: json['description'] as String?,
      downloadCount: (json['download_count'] as int?) ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'uploaded_by': uploadedBy,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'category': category,
      'description': description,
      'download_count': downloadCount,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

