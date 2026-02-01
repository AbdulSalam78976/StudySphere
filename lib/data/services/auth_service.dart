import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/services/supabase_service.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  final _supabase = SupabaseService.client;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      // Create user profile
      await _supabase.from(AppConstants.tableUsers).insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    return response;
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get current user profile
  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from(AppConstants.tableUsers)
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromJson(response);
  }

  // Update user profile
  Future<UserModel> updateProfile({
    String? fullName,
    String? bio,
    String? major,
    String? university,
    int? year,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (fullName != null) updates['full_name'] = fullName;
    if (bio != null) updates['bio'] = bio;
    if (major != null) updates['major'] = major;
    if (university != null) updates['university'] = university;
    if (year != null) updates['year'] = year;

    await _supabase
        .from(AppConstants.tableUsers)
        .update(updates)
        .eq('id', user.id);

    return (await getCurrentUser())!;
  }

  // Update avatar
  Future<String> updateAvatar(dynamic file) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}';
    await _supabase.storage
        .from(AppConstants.storageBucketAvatars)
        .upload(fileName, file);

    final avatarUrl = _supabase.storage
        .from(AppConstants.storageBucketAvatars)
        .getPublicUrl(fileName);

    await _supabase
        .from(AppConstants.tableUsers)
        .update({
          'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', user.id);

    return avatarUrl;
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
