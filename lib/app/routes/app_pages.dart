import 'package:get/get.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/signup_view.dart';
import '../../modules/dashboard/bindings/dashboard_binding.dart';
import '../../modules/dashboard/views/dashboard_view.dart';
import '../../modules/groups/bindings/groups_binding.dart';
import '../../modules/groups/views/groups_list_view.dart';
import '../../modules/groups/views/group_detail_view.dart';
import '../../modules/chat/views/chat_view.dart';
import '../../modules/resources/views/resources_view.dart';
import '../../modules/tasks/views/tasks_view.dart';
import '../../modules/profile/views/profile_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    // Auth Routes
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => SignupView(),
      binding: AuthBinding(),
    ),

    // Dashboard
    GetPage(
      name: Routes.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),

    // Groups
    GetPage(
      name: Routes.GROUPS,
      page: () => GroupsListView(),
      binding: GroupsBinding(),
    ),
    GetPage(
      name: Routes.GROUP_DETAIL,
      page: () => GroupDetailView(),
      binding: GroupsBinding(),
    ),

    // Chat
    GetPage(name: Routes.CHAT, page: () => ChatView()),

    // Resources
    GetPage(name: Routes.RESOURCES, page: () => ResourcesView()),

    // Tasks
    GetPage(name: Routes.TASKS, page: () => TasksView()),

    // Profile
    GetPage(name: Routes.PROFILE, page: () => ProfileView()),
  ];
}
