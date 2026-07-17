import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================
  // SIGN UP
  // ==========================
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user != null) {
      // Check if profile already exists
      final existing = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existing == null) {
        await _supabase.from('profiles').insert({
          'id': user.id,
          'username': email.split('@').first,
          'full_name': name,
          'bio': '',
          'avatar_url': '',
        });
      }
    }

    return response;
  }

  // ==========================
  // SIGN IN
  // ==========================
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ==========================
  // SIGN OUT
  // ==========================
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ==========================
  // CURRENT USER
  // ==========================
  User? get currentUser => _supabase.auth.currentUser;
}