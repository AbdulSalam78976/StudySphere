import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/task_service.dart';
import '../../../data/models/task_model.dart';

class TasksView extends StatefulWidget {
  final String? groupId;

  const TasksView({super.key, this.groupId});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  final TaskService _taskService = TaskService();
  final List<TaskModel> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.groupId != null) {
      _loadTasks();
    }
  }

  Future<void> _loadTasks() async {
    if (widget.groupId == null) return;
    setState(() => _isLoading = true);
    try {
      final tasks = await _taskService.getGroupTasks(widget.groupId!);
      setState(() {
        _tasks.clear();
        _tasks.addAll(tasks);
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tasks');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groupId == null) {
      return const Center(
        child: Text('No group selected'),
      );
    }

    return Scaffold(
      body: _isLoading && _tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_outlined,
                        size: 80,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Tasks Yet',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create tasks to organize your group work',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: CheckboxListTile(
                        value: task.status == TaskStatus.completed,
                        onChanged: (value) {
                          // Update task status
                        },
                        title: Text(task.title),
                        subtitle: task.description != null
                            ? Text(task.description!)
                            : null,
                        secondary: Icon(_getStatusIcon(task.status)),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show create task dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.inProgress:
        return Icons.play_circle;
      case TaskStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.radio_button_unchecked;
    }
  }
}

