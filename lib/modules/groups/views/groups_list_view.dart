import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/groups_controller.dart';
import '../../../data/models/group_model.dart';

class GroupsListView extends GetView<GroupsController> {
  const GroupsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateGroupDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.groups.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isSearching.value) {
          return _buildSearchResults(context);
        }

        if (controller.groups.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.loadGroups,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.groups.length,
            itemBuilder: (context, index) {
              final group = controller.groups[index];
              return _buildGroupCard(context, group);
            },
          ),
        );
      }),
    );
  }

  Widget _buildGroupCard(BuildContext context, GroupModel group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            group.name[0].toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.courseName != null) ...[
              const SizedBox(height: 4),
              Text(group.courseName!),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text('${group.memberCount} members'),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => controller.navigateToGroupDetail(group.id),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Groups Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create or join a study group to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateGroupDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Group'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.searchResults.isEmpty) {
      return Center(
        child: Text(
          'No groups found',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final group = controller.searchResults[index];
        return _buildGroupCard(context, group);
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Search Groups'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search by name, course, or description...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onChanged: (value) {
            controller.searchQuery.value = value;
            controller.searchGroups(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.searchQuery.value = '';
              controller.searchResults.clear();
              controller.isSearching.value = false;
              Get.back();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final courseCodeController = TextEditingController();
    final courseNameController = TextEditingController();
    final isPrivate = false.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Create Study Group'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name *',
                  hintText: 'e.g., Data Structures Study Group',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: courseCodeController,
                decoration: const InputDecoration(
                  labelText: 'Course Code',
                  hintText: 'e.g., CS201',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: courseNameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  hintText: 'e.g., Data Structures and Algorithms',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What is this group about?',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Obx(() => CheckboxListTile(
                    title: const Text('Private Group'),
                    subtitle: const Text('Only members can see this group'),
                    value: isPrivate.value,
                    onChanged: (value) => isPrivate.value = value ?? false,
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (nameController.text.trim().isEmpty) {
                          Get.snackbar('Error', 'Group name is required');
                          return;
                        }
                        controller.createGroup(
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim().isEmpty
                              ? null
                              : descriptionController.text.trim(),
                          courseCode: courseCodeController.text.trim().isEmpty
                              ? null
                              : courseCodeController.text.trim(),
                          courseName: courseNameController.text.trim().isEmpty
                              ? null
                              : courseNameController.text.trim(),
                          isPrivate: isPrivate.value,
                        );
                      },
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              )),
        ],
      ),
    );
  }
}

