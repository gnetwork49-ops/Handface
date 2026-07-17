import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_service.dart';

class FollowService {
  final SupabaseClient _supabase = Supabase.instance.client;

  final NotificationService _notificationService =
      NotificationService();

  // FOLLOW USER
  Future<void> followUser(String userId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) return;

    // Don't allow following yourself
    if (user.id == userId) return;

    // Check if already following
    final existing = await _supabase
        .from('followers')
        .select()
        .eq('follower_id', user.id)
        .eq('following_id', userId);

    if (existing.isNotEmpty) return;

    // Save follow
    await _supabase.from('followers').insert({
      'follower_id': user.id,
      'following_id': userId,
    });

    // Create notification
    await _notificationService.createNotification(
      recipientId: userId,
      senderId: user.id,
      type: 'follow',
      message: 'started following you 👤',
    );
  }

  // UNFOLLOW USER
  Future<void> unfollowUser(String userId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) return;

    await _supabase
        .from('followers')
        .delete()
        .eq('follower_id', user.id)
        .eq('following_id', userId);
  }

  // CHECK IF FOLLOWING
  Future<bool> isFollowing(String userId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) return false;

    final result = await _supabase
        .from('followers')
        .select()
        .eq('follower_id', user.id)
        .eq('following_id', userId);

    return result.isNotEmpty;
  }

  // FOLLOWERS COUNT
  Future<int> followersCount(String userId) async {
    final result = await _supabase
        .from('followers')
        .select()
        .eq('following_id', userId);

    return result.length;
  }

  // FOLLOWING COUNT
  Future<int> followingCount(String userId) async {
    final result = await _supabase
        .from('followers')
        .select()
        .eq('follower_id', userId);

    return result.length;
  }
}