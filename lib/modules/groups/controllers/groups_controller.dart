import 'package:get/get.dart';
import '../../../data/services/group_service.dart';
import '../../../data/models/group_model.dart';
import '../../../app/routes/app_pages.dart';

class GroupsController extends GetxController {
  final GroupService _groupService = GroupService();

  final RxBool isLoading = false.obs;
  final RxList<GroupModel> groups = <GroupModel>[].obs;
  final RxList<GroupModel> searchResults = <GroupModel>[].obs;
  final Rx<GroupModel?> selectedGroup = Rx<GroupModel?>(null);
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  Future<void> loadGroups() async {
    isLoading.value = true;
    try {
      final userGroups = await _groupService.getUserGroups();
      groups.value = userGroups;
    } catch (e) {
      print('Error loading groups: $e');
      Get.snackbar('Error', 'Failed to load groups');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchGroups(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    try {
      final results = await _groupService.searchGroups(query);
      searchResults.value = results;
    } catch (e) {
      print('Error searching groups: $e');
      Get.snackbar('Error', 'Failed to search groups');
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> createGroup({
    required String name,
    String? description,
    String? courseCode,
    String? courseName,
    bool isPrivate = false,
  }) async {
    isLoading.value = true;
    try {
      final group = await _groupService.createGroup(
        name: name,
        description: description,
        courseCode: courseCode,
        courseName: courseName,
        isPrivate: isPrivate,
      );
      groups.insert(0, group);
      Get.back();
      Get.snackbar('Success', 'Group created successfully!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinGroup(String groupId) async {
    isLoading.value = true;
    try {
      await _groupService.joinGroup(groupId);
      await loadGroups();
      Get.snackbar('Success', 'Joined group successfully!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> leaveGroup(String groupId) async {
    isLoading.value = true;
    try {
      await _groupService.leaveGroup(groupId);
      await loadGroups();
      Get.snackbar('Success', 'Left group successfully!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToGroupDetail(String groupId) {
    Get.toNamed(Routes.GROUP_DETAIL, arguments: {'groupId': groupId});
  }

  void loadGroupDetail(String groupId) async {
    isLoading.value = true;
    try {
      final group = await _groupService.getGroupById(groupId);
      selectedGroup.value = group;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load group details');
    } finally {
      isLoading.value = false;
    }
  }
}

