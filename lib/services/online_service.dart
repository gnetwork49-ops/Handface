import 'package:supabase_flutter/supabase_flutter.dart';

class OnlineService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get user => _supabase.auth.currentUser;

  // ==========================
  // GO ONLINE
  // ==========================
  Future<void> goOnline() async {
    if (user == null) return;

    await _supabase.from('online_users').upsert({
      'user_id': user!.id,
      'is_online': true,
      'last_seen': DateTime.now().toIso8601String(),
    });
  }

  // ==========================
  // GO OFFLINE
  // ==========================
  Future<void> goOffline() async {
    if (user == null) return;

    await _supabase.from('online_users').upsert({
      'user_id': user!.id,
      'is_online': false,
      'last_seen': DateTime.now().toIso8601String(),
    });
  }

  // ==========================
  // GET USER STATUS
  // ==========================
  Future<Map<String, dynamic>?> getUserStatus(
      String userId) async {
    final result = await _supabase
        .from('online_users')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    return result;
  }
}