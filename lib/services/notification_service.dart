import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createNotification({
    required String recipientId,
    required String senderId,
    String? postId,
    required String type,
    required String message,
  }) async {
    if (recipientId == senderId) return;

   await _supabase.from('notifications').insert({
  'recipient_id': recipientId,
  'actor_id': senderId,
  'reference_id': postId,
  'type': type,
});
  }

Future<List<Map<String, dynamic>>> getNotifications() async {
  final user = _supabase.auth.currentUser;

  if (user == null) return [];

  final response = await _supabase
      .from('notifications')
      .select('''
        *,
        profiles!actor_id(
          id,
          full_name,
          username,
          avatar_url
        )
      ''')
      .eq('recipient_id', user.id)
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
}
  Future<void> markAsRead(String id) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }
}