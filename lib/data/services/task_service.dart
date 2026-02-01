import '../../shared/services/supabase_service.dart';
import '../models/task_model.dart';
import '../../core/constants/app_constants.dart';

class TaskService {
  final _supabase = SupabaseService.client;

  // Create task
  Future<TaskModel> createTask({
    required String groupId,
    required String title,
    String? description,
    String? assignedTo,
    DateTime? dueDate,
    int priority = 3,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final taskData = {
      'group_id': groupId,
      'title': title,
      'description': description,
      'created_by': user.id,
      'assigned_to': assignedTo,
      'status': TaskStatus.todo.toString().split('.').last,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase
        .from(AppConstants.tableTasks)
        .insert(taskData)
        .select()
        .single();

    return TaskModel.fromJson(response);
  }

  // Get tasks for a group
  Future<List<TaskModel>> getGroupTasks(
    String groupId, {
    TaskStatus? status,
    String? assignedTo,
  }) async {
    var query = _supabase
        .from(AppConstants.tableTasks)
        .select()
        .eq('group_id', groupId);

    if (status != null) {
      query = query.eq('status', status.toString().split('.').last);
    }

    if (assignedTo != null) {
      query = query.eq('assigned_to', assignedTo);
    }

    final response = await query
        .order('created_at', ascending: false);

    return (response as List)
        .map((t) => TaskModel.fromJson(t))
        .toList();
  }

  // Get task by ID
  Future<TaskModel?> getTaskById(String taskId) async {
    final response = await _supabase
        .from(AppConstants.tableTasks)
        .select()
        .eq('id', taskId)
        .maybeSingle();

    if (response == null) return null;
    return TaskModel.fromJson(response);
  }

  // Update task
  Future<TaskModel> updateTask(
    String taskId, {
    String? title,
    String? description,
    String? assignedTo,
    TaskStatus? status,
    DateTime? dueDate,
    int? priority,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (assignedTo != null) updates['assigned_to'] = assignedTo;
    if (status != null) {
      updates['status'] = status.toString().split('.').last;
    }
    if (dueDate != null) updates['due_date'] = dueDate.toIso8601String();
    if (priority != null) updates['priority'] = priority;

    final response = await _supabase
        .from(AppConstants.tableTasks)
        .update(updates)
        .eq('id', taskId)
        .select()
        .single();

    return TaskModel.fromJson(response);
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get task to check ownership
    final task = await getTaskById(taskId);
    if (task == null) throw Exception('Task not found');

    if (task.createdBy != user.id) {
      throw Exception('Only the creator can delete this task');
    }

    await _supabase.from(AppConstants.tableTasks).delete().eq('id', taskId);
  }

  // Get user's assigned tasks
  Future<List<TaskModel>> getUserTasks(String groupId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from(AppConstants.tableTasks)
        .select()
        .eq('group_id', groupId)
        .eq('assigned_to', user.id)
        .order('due_date', ascending: true);

    return (response as List)
        .map((t) => TaskModel.fromJson(t))
        .toList();
  }
}

