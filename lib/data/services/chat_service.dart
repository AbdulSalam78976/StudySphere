import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/services/supabase_service.dart';
import '../models/message_model.dart';
import '../../core/constants/app_constants.dart';

class ChatService {
  final _supabase = SupabaseService.client;
  
  SupabaseClient get client => _supabase;

  // Send message
  Future<MessageModel> sendMessage({
    required String groupId,
    required String content,
    String? fileUrl,
    String? fileType,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get user info for sender details
    final userResponse = await _supabase
        .from(AppConstants.tableUsers)
        .select('full_name, avatar_url')
        .eq('id', user.id)
        .single();

    final messageData = {
      'group_id': groupId,
      'sender_id': user.id,
      'sender_name': userResponse['full_name'],
      'sender_avatar': userResponse['avatar_url'],
      'content': content,
      'file_url': fileUrl,
      'file_type': fileType,
      'created_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase
        .from(AppConstants.tableMessages)
        .insert(messageData)
        .select()
        .single();

    return MessageModel.fromJson(response);
  }

  // Get messages for a group
  Future<List<MessageModel>> getGroupMessages(
    String groupId, {
    int limit = 50,
    DateTime? before,
  }) async {
    var query = _supabase
        .from(AppConstants.tableMessages)
        .select()
        .eq('group_id', groupId);

    if (before != null) {
      query = query.lt('created_at', before.toIso8601String());
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    final messages = (response as List)
        .map((m) => MessageModel.fromJson(m))
        .toList();

    // Reverse to show oldest first
    return messages.reversed.toList();
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get message to check ownership
    final response = await _supabase
        .from(AppConstants.tableMessages)
        .select('sender_id')
        .eq('id', messageId)
        .single();

    if (response['sender_id'] != user.id) {
      throw Exception('Only the sender can delete this message');
    }

    await _supabase
        .from(AppConstants.tableMessages)
        .delete()
        .eq('id', messageId);
  }

  // Update message
  Future<MessageModel> updateMessage(
    String messageId,
    String content,
  ) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get message to check ownership
    final messageResponse = await _supabase
        .from(AppConstants.tableMessages)
        .select('sender_id')
        .eq('id', messageId)
        .single();

    if (messageResponse['sender_id'] != user.id) {
      throw Exception('Only the sender can edit this message');
    }

    final response = await _supabase
        .from(AppConstants.tableMessages)
        .update({
          'content': content,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', messageId)
        .select()
        .single();

    return MessageModel.fromJson(response);
  }

  // Subscribe to real-time messages
  RealtimeChannel subscribeToMessages(String groupId, Function(MessageModel) onNewMessage) {
    return _supabase
        .channel('group_messages_$groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: AppConstants.tableMessages,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (payload) {
            final message = MessageModel.fromJson(payload.newRecord);
            onNewMessage(message);
          },
        )
        .subscribe();
  }

  // Unsubscribe from messages
  Future<void> unsubscribeFromMessages(RealtimeChannel channel) async {
    await _supabase.removeChannel(channel);
  }
}

