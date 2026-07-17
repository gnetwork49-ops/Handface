import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================
  // GET MY PROFILE
  // ==========================
  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) return null;

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return response;
  }

  // ==========================
  // GET MY POSTS
  // ==========================
  Future<List<Map<String, dynamic>>> getMyPosts() async {
    final user = _supabase.auth.currentUser;

    if (user == null) return [];

    final response = await _supabase
        .from('posts')
        .select()
        .eq('author_id', user.id)
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ==========================
  // UPDATE PROFILE
  // ==========================
  Future<void> updateProfile({
    required String fullName,
    required String username,
    required String bio,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await _supabase.from('profiles').update({
      'full_name': fullName,
      'username': username,
      'bio': bio,
    }).eq('id', user.id);
  }

  // ==========================
  // UPDATE AVATAR
  // ==========================
  Future<void> updateAvatar(String avatarUrl) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await _supabase.from('profiles').update({
      'avatar_url': avatarUrl,
    }).eq('id', user.id);
  }
}