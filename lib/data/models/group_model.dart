class GroupModel {
  final String id;
  final String name;
  final String? description;
  final String? courseCode;
  final String? courseName;
  final String? avatarUrl;
  final String createdBy;
  final int memberCount;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.courseCode,
    this.courseName,
    this.avatarUrl,
    required this.createdBy,
    this.memberCount = 0,
    this.isPrivate = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      courseCode: json['course_code'] as String?,
      courseName: json['course_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdBy: json['created_by'] as String,
      memberCount: (json['member_count'] as int?) ?? 0,
      isPrivate: (json['is_private'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'course_code': courseCode,
      'course_name': courseName,
      'avatar_url': avatarUrl,
      'created_by': createdBy,
      'member_count': memberCount,
      'is_private': isPrivate,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? courseCode,
    String? courseName,
    String? avatarUrl,
    String? createdBy,
    int? memberCount,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdBy: createdBy ?? this.createdBy,
      memberCount: memberCount ?? this.memberCount,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
