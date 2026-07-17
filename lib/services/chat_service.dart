import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================
  // CURRENT USER
  // ==========================
  User? get currentUser => _supabase.auth.currentUser;

  // ==========================
  // CREATE OR GET CONVERSATION
  // ==========================
  Future<String> createOrGetConversation(
      String otherUserId) async {
    final me = currentUser;

    if (me == null) {
      throw Exception("User not logged in");
    }

    final myConversations = await _supabase
        .from('conversation_participants')
        .select('conversation_id')
        .eq('user_id', me.id);

    for (final row in myConversations) {
      final conversationId = row['conversation_id'];

      final participants = await _supabase
          .from('conversation_participants')
          .select('user_id')
          .eq('conversation_id', conversationId);

      final ids = participants
          .map((e) => e['user_id'] as String)
          .toList();

      if (ids.length == 2 &&
          ids.contains(me.id) &&
          ids.contains(otherUserId)) {
        return conversationId;
      }
    }

    final conversation = await _supabase
        .from('conversations')
        .insert({
          'type': 'direct',
          'created_by': me.id,
        })
        .select()
        .single();

    final conversationId = conversation['id'];

    await _supabase
        .from('conversation_participants')
        .insert([
      {
        'conversation_id': conversationId,
        'user_id': me.id,
      },
      {
        'conversation_id': conversationId,
        'user_id': otherUserId,
      },
    ]);

    return conversationId;
  }

  // ==========================
  // SEND MESSAGE
  // ==========================
  Future<void> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    final me = currentUser;

    if (me == null) return;

    await _supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': me.id,
      'message': message,
    });
  }

  // ==========================
  // LOAD MESSAGES
  // ==========================
  Future<List<Map<String, dynamic>>> getMessages(
      String conversationId) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  // ==========================
  // REALTIME MESSAGES
  // ==========================
  Stream<List<Map<String, dynamic>>> messageStream(
      String conversationId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at');
  }

  // ==========================
  // MY CONVERSATIONS
  // ==========================
  Future<List<Map<String, dynamic>>> getMyConversations() async {
    final me = currentUser;

    if (me == null) return [];

    final participantRows = await _supabase
        .from('conversation_participants')
        .select('conversation_id')
        .eq('user_id', me.id);

    List<Map<String, dynamic>> conversations = [];

    for (final row in participantRows) {
      final conversationId = row['conversation_id'];

      final participants = await _supabase
          .from('conversation_participants')
          .select('user_id')
          .eq('conversation_id', conversationId);

      String? otherUserId;

      for (final p in participants) {
        if (p['user_id'] != me.id) {
          otherUserId = p['user_id'];
          break;
        }
      }

      if (otherUserId == null) continue;

      final profile = await _supabase
          .from('profiles')
          .select(
              'id, full_name, username, avatar_url')
          .eq('id', otherUserId)
          .single();

      final lastMessages = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at',
              ascending: false)
          .limit(1);

      Map<String, dynamic>? lastMessage;

      if (lastMessages.isNotEmpty) {
        lastMessage = lastMessages.first;
      }

      conversations.add({
        'conversation_id': conversationId,
        'profile': profile,
        'last_message': lastMessage,
      });
    }

    conversations.sort((a, b) {
      final aTime =
          a['last_message']?['created_at'] ?? '';

      final bTime =
          b['last_message']?['created_at'] ?? '';

      return bTime.compareTo(aTime);
    });

    return conversations;
  }

  // ==========================
  // GET OTHER USER
  // ==========================
  Future<Map<String, dynamic>>
      getConversationUser(
          String conversationId) async {
    final me = currentUser;

    if (me == null) {
      throw Exception("User not logged in");
    }

    final participants = await _supabase
        .from('conversation_participants')
        .select('user_id')
        .eq('conversation_id', conversationId);

    String? otherUserId;

    for (final p in participants) {
      if (p['user_id'] != me.id) {
        otherUserId = p['user_id'];
        break;
      }
    }

    if (otherUserId == null) {
      throw Exception("User not found");
    }

    final profile = await _supabase
        .from('profiles')
        .select(
            'id, full_name, username, avatar_url')
        .eq('id', otherUserId)
        .single();

    return profile;
  }
}