import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../app/routes/app_pages.dart';
import '../../../shared/services/supabase_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isLoading = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool showPassword = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthState();
    _authService.authStateChanges.listen((authState) {
      if (authState.session != null) {
        loadCurrentUser();
      } else {
        currentUser.value = null;
        isAuthenticated.value = false;
      }
    });
  }

  Future<void> checkAuthState() async {
    isLoading.value = true;
    try {
      if (SupabaseService.isAuthenticated) {
        await loadCurrentUser();
      }
    } catch (e) {
      print('Error checking auth state: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      currentUser.value = user;
      isAuthenticated.value = user != null;
    } catch (e) {
      print('Error loading current user: $e');
      currentUser.value = null;
      isAuthenticated.value = false;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    isLoading.value = true;
    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      await loadCurrentUser();
      Get.offAllNamed(Routes.DASHBOARD);
      Get.snackbar('Success', 'Account created successfully!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    isLoading.value = true;
    try {
      await _authService.signIn(email: email, password: password);
      await loadCurrentUser();
      Get.offAllNamed(Routes.DASHBOARD);
      Get.snackbar('Success', 'Signed in successfully!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await _authService.signOut();
      currentUser.value = null;
      isAuthenticated.value = false;
      Get.offAllNamed(Routes.LOGIN);
      Get.snackbar('Success', 'Signed out successfully!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    isLoading.value = true;
    try {
      await _authService.resetPassword(email);
      Get.snackbar('Success', 'Password reset email sent!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
