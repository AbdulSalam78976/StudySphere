import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/services/supabase_service.dart';
import '../models/group_model.dart';
import '../../core/constants/app_constants.dart';

class GroupService {
  final _supabase = SupabaseService.client;

  // Create a new group
  Future<GroupModel> createGroup({
    required String name,
    String? description,
    String? courseCode,
    String? courseName,
    bool isPrivate = false,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final groupData = {
      'name': name,
      'description': description,
      'course_code': courseCode,
      'course_name': courseName,
      'created_by': user.id,
      'is_private': isPrivate,
      'member_count': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase
        .from(AppConstants.tableGroups)
        .insert(groupData)
        .select()
        .single();

    final group = GroupModel.fromJson(response);

    // Add creator as member
    await _supabase.from(AppConstants.tableGroupMembers).insert({
      'group_id': group.id,
      'user_id': user.id,
      'role': 'admin',
      'joined_at': DateTime.now().toIso8601String(),
    });

    return group;
  }

  // Get user's groups
  Future<List<GroupModel>> getUserGroups() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final memberResponse = await _supabase
        .from(AppConstants.tableGroupMembers)
        .select('group_id')
        .eq('user_id', user.id);

    if (memberResponse.isEmpty) return [];

    final groupIds = (memberResponse as List)
        .map((m) => m['group_id'] as String)
        .toList();

    if (groupIds.isEmpty) return [];

    // Fetch groups one by one or use a workaround
    // Note: Supabase Flutter may have different API - adjust based on your version
    final List<Map<String, dynamic>> allGroups = [];
    for (final groupId in groupIds) {
      try {
        final response = await _supabase
            .from(AppConstants.tableGroups)
            .select()
            .eq('id', groupId)
            .maybeSingle();
        if (response != null) {
          allGroups.add(response);
        }
      } catch (e) {
        print('Error fetching group $groupId: $e');
      }
    }

    // Sort by updated_at
    allGroups.sort((a, b) {
      final aDate = DateTime.parse(a['updated_at'] as String);
      final bDate = DateTime.parse(b['updated_at'] as String);
      return bDate.compareTo(aDate);
    });

    final groupsResponse = allGroups;

    return (groupsResponse as List).map((g) => GroupModel.fromJson(g)).toList();
  }

  // Get group by ID
  Future<GroupModel?> getGroupById(String groupId) async {
    try {
      final response = await _supabase
          .from(AppConstants.tableGroups)
          .select()
          .eq('id', groupId)
          .maybeSingle();

      if (response == null) return null;
      return GroupModel.fromJson(response);
    } catch (e) {
      print('Error fetching group: $e');
      return null;
    }
  }

  // Search groups
  Future<List<GroupModel>> searchGroups(String query) async {
    final response = await _supabase
        .from(AppConstants.tableGroups)
        .select()
        .or(
          'name.ilike.%$query%,description.ilike.%$query%,course_name.ilike.%$query%,course_code.ilike.%$query%',
        )
        .eq('is_private', false)
        .order('created_at', ascending: false)
        .limit(AppConstants.itemsPerPage);

    return (response as List).map((g) => GroupModel.fromJson(g)).toList();
  }

  // Join group
  Future<void> joinGroup(String groupId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if already a member
    final existing = await _supabase
        .from(AppConstants.tableGroupMembers)
        .select()
        .eq('group_id', groupId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing != null) {
      throw Exception('Already a member of this group');
    }

    // Add as member
    await _supabase.from(AppConstants.tableGroupMembers).insert({
      'group_id': groupId,
      'user_id': user.id,
      'role': 'member',
      'joined_at': DateTime.now().toIso8601String(),
    });

    // Update member count
    await _supabase.rpc(
      'increment_group_member_count',
      params: {'group_id': groupId},
    );
  }

  // Leave group
  Future<void> leaveGroup(String groupId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase
        .from(AppConstants.tableGroupMembers)
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', user.id);

    // Update member count
    await _supabase.rpc(
      'decrement_group_member_count',
      params: {'group_id': groupId},
    );
  }

  // Update group
  Future<GroupModel> updateGroup(
    String groupId, {
    String? name,
    String? description,
    String? courseCode,
    String? courseName,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (courseCode != null) updates['course_code'] = courseCode;
    if (courseName != null) updates['course_name'] = courseName;

    final response = await _supabase
        .from(AppConstants.tableGroups)
        .update(updates)
        .eq('id', groupId)
        .select()
        .single();

    return GroupModel.fromJson(response);
  }

  // Delete group
  Future<void> deleteGroup(String groupId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Verify user is admin
    final member = await _supabase
        .from(AppConstants.tableGroupMembers)
        .select()
        .eq('group_id', groupId)
        .eq('user_id', user.id)
        .eq('role', 'admin')
        .maybeSingle();

    if (member == null) {
      throw Exception('Only admins can delete groups');
    }

    await _supabase.from(AppConstants.tableGroups).delete().eq('id', groupId);
  }

  // Get group members
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final response = await _supabase
        .from(AppConstants.tableGroupMembers)
        .select('''
          *,
          user:users(id, full_name, avatar_url, email)
        ''')
        .eq('group_id', groupId)
        .order('joined_at', ascending: true);

    return (response as List).cast<Map<String, dynamic>>();
  }

  // Real-time subscription for groups
  RealtimeChannel subscribeToGroups() {
    return _supabase
        .channel('groups_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppConstants.tableGroups,
          callback: (payload) {
            // Handle real-time updates
          },
        )
        .subscribe();
  }
}
