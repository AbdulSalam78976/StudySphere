import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../groups/views/groups_list_view.dart';
import '../../resources/views/resources_view.dart';
import '../../tasks/views/tasks_view.dart';
import '../../profile/views/profile_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              GroupsListView(),
              ResourcesView(),
              TasksView(),
              ProfileView(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.currentIndex.value,
            onDestinationSelected: (index) {
              controller.changeTab(index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups),
                label: 'Groups',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder),
                label: 'Resources',
              ),
              NavigationDestination(
                icon: Icon(Icons.task_outlined),
                selectedIcon: Icon(Icons.task),
                label: 'Tasks',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outlined),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ));
  }
}

