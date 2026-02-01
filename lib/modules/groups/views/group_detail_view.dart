import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/groups_controller.dart';
import '../../chat/views/chat_view.dart';
import '../../resources/views/resources_view.dart';
import '../../tasks/views/tasks_view.dart';

class GroupDetailView extends GetView<GroupsController> {
  const GroupDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final groupId = Get.arguments?['groupId'] as String?;
    if (groupId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group Details')),
        body: const Center(child: Text('Group ID not provided')),
      );
    }

    controller.loadGroupDetail(groupId);

    return Obx(() {
      final group = controller.selectedGroup.value;
      if (group == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Group Details')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(group.name),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.chat), text: 'Chat'),
                Tab(icon: Icon(Icons.folder), text: 'Resources'),
                Tab(icon: Icon(Icons.task), text: 'Tasks'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ChatView(groupId: group.id),
              ResourcesView(groupId: group.id),
              TasksView(groupId: group.id),
            ],
          ),
        ),
      );
    });
  }
}

