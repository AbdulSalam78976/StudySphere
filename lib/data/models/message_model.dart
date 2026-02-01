class MessageModel {
  final String id;
  final String groupId;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final String content;
  final String? fileUrl;
  final String? fileType;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MessageModel({
    required this.id,
    required this.groupId,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.content,
    this.fileUrl,
    this.fileType,
    required this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String?,
      senderAvatar: json['sender_avatar'] as String?,
      content: json['content'] as String,
      fileUrl: json['file_url'] as String?,
      fileType: json['file_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'content': content,
      'file_url': fileUrl,
      'file_type': fileType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
}

