enum TaskStatus { todo, inProgress, completed, cancelled }

class TaskModel {
  final String id;
  final String groupId;
  final String title;
  final String? description;
  final String createdBy;
  final String? assignedTo;
  final TaskStatus status;
  final DateTime? dueDate;
  final int priority; // 1-5, 5 being highest
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.groupId,
    required this.title,
    this.description,
    required this.createdBy,
    this.assignedTo,
    this.status = TaskStatus.todo,
    this.dueDate,
    this.priority = 3,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdBy: json['created_by'] as String,
      assignedTo: json['assigned_to'] as String?,
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      priority: (json['priority'] as int?) ?? 3,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'title': title,
      'description': description,
      'created_by': createdBy,
      'assigned_to': assignedTo,
      'status': status.toString().split('.').last,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return dueDate!.isBefore(DateTime.now());
  }
}
