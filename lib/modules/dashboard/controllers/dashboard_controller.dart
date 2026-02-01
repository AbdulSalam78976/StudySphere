import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/group_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/group_model.dart';
import '../../../app/routes/app_pages.dart';

class DashboardController extends GetxController {
  final AuthService _authService = AuthService();
  final GroupService _groupService = GroupService();

  final RxBool isLoading = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxList<GroupModel> myGroups = <GroupModel>[].obs;
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadMyGroups();
  }

  Future<void> loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      currentUser.value = user;
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> loadMyGroups() async {
    isLoading.value = true;
    try {
      final groups = await _groupService.getUserGroups();
      myGroups.value = groups;
    } catch (e) {
      print('Error loading groups: $e');
      Get.snackbar('Error', 'Failed to load groups');
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void navigateToGroups() {
    Get.toNamed(Routes.GROUPS);
  }

  void navigateToGroupDetail(String groupId) {
    Get.toNamed(Routes.GROUP_DETAIL, arguments: {'groupId': groupId});
  }

  void navigateToProfile() {
    Get.toNamed(Routes.PROFILE);
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out');
    }
  }
}

