import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_service.dart';

class CommentService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationService _notificationService =
      NotificationService();

  // ADD COMMENT
  Future<void> addComment({
    required String postId,
    required String comment,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) return;

    // Save comment
    await _supabase.from('comments').insert({
      'post_id': postId,
      'user_id': user.id,
      'comment': comment,
    });

    // Find post owner
    final post = await _supabase
        .from('posts')
        .select('author_id')
        .eq('id', postId)
        .single();

    final recipientId = post['author_id'] as String;

    // Don't notify yourself
    if (recipientId != user.id) {
      await _notificationService.createNotification(
        recipientId: recipientId,
        senderId: user.id,
        postId: postId,
        type: 'comment',
        message: 'commented on your post 💬',
      );
    }
  }

  // GET COMMENTS
  Future<List<Map<String, dynamic>>> getComments(
      String postId) async {
    final response = await _supabase
        .from('comments')
        .select('''
  *,
  profiles!comments_user_id_fkey(
    id,
    full_name,
    username,
    avatar_url
  )
''')
        .eq('post_id', postId)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  // COMMENT COUNT
  Future<int> getCommentCount(String postId) async {
    final result = await _supabase
        .from('comments')
        .select()
        .eq('post_id', postId);

    return result.length;
  }
}