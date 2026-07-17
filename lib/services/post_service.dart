import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_service.dart';

class PostService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationService _notificationService =
      NotificationService();

  // ==========================
  // CREATE POST
  // ==========================
  Future<void> createPost({
    required String caption,
    String? imageUrl,
    String? videoUrl,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await _supabase.from('posts').insert({
      'author_id': user.id,
      'content': caption,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'visibility': 'public',
    });
  }

  // ==========================
// GET HOME FEED (POSTS + REPOSTS)
// ==========================
Future<List<Map<String, dynamic>>> getPosts() async {
  // Load normal posts
  final posts = await _supabase
      .from('posts')
      .select('''
        *,
        profiles!author_id(
          id,
          full_name,
          username,
          avatar_url
        )
      ''')
      .order('created_at', ascending: false);

  // Load reposts
  final reposts = await _supabase
      .from('reposts')
      .select('post_id, user_id, created_at')
      .order('created_at', ascending: false);

  List<Map<String, dynamic>> feed = [];

  // Add normal posts
  for (final post in posts) {
    feed.add({
      ...post,
      'feed_type': 'post',
      'feed_time': post['created_at'],
    });
  }

  // Add reposts
  for (final repost in reposts) {
    // Get the reposted post
    final post = await _supabase
        .from('posts')
        .select('''
          *,
          profiles!author_id(
            id,
            full_name,
            username,
            avatar_url
          )
        ''')
        .eq('id', repost['post_id'])
        .single();

    // Get reposter profile
    final profile = await _supabase
        .from('profiles')
        .select('id, full_name, username, avatar_url')
        .eq('id', repost['user_id'])
        .single();

    feed.add({
      ...post,
      'feed_type': 'repost',
      'feed_time': repost['created_at'],
      'reposted_by': profile,
    });
  }

  // Sort newest first
  feed.sort(
    (a, b) => DateTime.parse(b['feed_time'])
        .compareTo(DateTime.parse(a['feed_time'])),
  );

  return feed;
}
  // ==========================
  // GET VIDEO POSTS (REELS)
  // ==========================
  Future<List<Map<String, dynamic>>> getVideoPosts() async {
    final response = await _supabase
        .from('posts')
        .select('''
          *,
          profiles!author_id(
            id,
            full_name,
            username,
            avatar_url
          )
        ''')
        .not('video_url', 'is', null)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response)
        .where(
          (post) =>
              post['video_url'] != null &&
              post['video_url'].toString().isNotEmpty,
        )
        .toList();
  }

  // ==========================
  // GET USER POSTS
  // ==========================
  Future<List<Map<String, dynamic>>> getUserPosts(
      String userId) async {
    final response = await _supabase
        .from('posts')
        .select('''
          *,
          profiles!author_id(
            id,
            full_name,
            username,
            avatar_url
          )
        ''')
        .eq('author_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ==========================
  // LIKE POST
  // ==========================
  Future<void> likePost(String postId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) return;

    final existing = await _supabase
        .from('likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', user.id);

    if (existing.isNotEmpty) return;

    await _supabase.from('likes').insert({
      'post_id': postId,
      'user_id': user.id,
    });

    final post = await _supabase
        .from('posts')
        .select('author_id')
        .eq('id', postId)
        .single();

    final recipientId = post['author_id'];

    if (recipientId != user.id) {
      await _notificationService.createNotification(
        recipientId: recipientId,
        senderId: user.id,
        postId: postId,
        type: 'like',
        message: 'liked your post ❤️',
      );
    }
  }

  // ==========================
  // UNLIKE POST
  // ==========================
  Future<void> unlikePost(String postId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) return;

    await _supabase
        .from('likes')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', user.id);
  }

  // ==========================
  // HAS LIKED
  // ==========================
  Future<bool> hasLiked(String postId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) return false;

    final result = await _supabase
        .from('likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', user.id);

    return result.isNotEmpty;
  }

  // ==========================
  // LIKE COUNT
  // ==========================
  Future<int> getLikeCount(String postId) async {
    final result = await _supabase
        .from('likes')
        .select()
        .eq('post_id', postId);

    return result.length;
  }
  // ==========================
  // REPOST POST
  // ==========================
  Future<void> repost(String postId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) return;

    final existing = await _supabase
        .from('reposts')
        .select()
        .eq('post_id', postId)
        .eq('user_id', user.id);

    if (existing.isNotEmpty) return;

    await _supabase.from('reposts').insert({
      'post_id': postId,
      'user_id': user.id,
    });

    final post = await _supabase
        .from('posts')
        .select('author_id')
        .eq('id', postId)
        .single();

    final recipientId = post['author_id'];

    if (recipientId != user.id) {
      await _notificationService.createNotification(
        recipientId: recipientId,
        senderId: user.id,
        postId: postId,
        type: 'repost',
        message: 'reposted your post 🔁',
      );
    }
  }

  // ==========================
  // REMOVE REPOST
  // ==========================
  Future<void> removeRepost(String postId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) return;

    await _supabase
        .from('reposts')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', user.id);
  }

  // ==========================
  // HAS REPOSTED
  // ==========================
  Future<bool> hasReposted(String postId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) return false;

    final result = await _supabase
        .from('reposts')
        .select()
        .eq('post_id', postId)
        .eq('user_id', user.id);

    return result.isNotEmpty;
  }

  // ==========================
  // REPOST COUNT
  // ==========================
  Future<int> getRepostCount(String postId) async {
    final result = await _supabase
        .from('reposts')
        .select()
        .eq('post_id', postId);

    return result.length;
  }
}
