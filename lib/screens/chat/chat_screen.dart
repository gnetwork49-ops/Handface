import 'package:flutter/material.dart';

import '../../services/chat_service.dart';
import 'conversation_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();

  Future<void> _refresh() async {
    setState(() {});
  }

  String _formatTime(String? time) {
    if (time == null) return "";

    final date = DateTime.parse(time).toLocal();

    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
            ? 12
            : date.hour;

    final minute =
        date.minute.toString().padLeft(2, '0');

    final ampm =
        date.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $ampm";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _chatService.getMyConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final conversations =
              snapshot.data ?? [];

          if (conversations.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 250),
                  Center(
                    child: Text(
                      "No conversations yet",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1),
              itemBuilder: (context, index) {
                final conversation =
                    conversations[index];

                final profile =
                    conversation['profile'];

                final last =
                    conversation['last_message'];

                return ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage:
                        profile['avatar_url'] !=
                                    null &&
                                profile['avatar_url']
                                    .toString()
                                    .isNotEmpty
                            ? NetworkImage(
                                profile['avatar_url'])
                            : null,
                    child: profile['avatar_url'] ==
                                null ||
                            profile['avatar_url']
                                .toString()
                                .isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),

                  title: Text(
                    profile['full_name'] ??
                        profile['username'],
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    last == null
                        ? "Start chatting..."
                        : last['message'],
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                  ),

                  trailing: Text(
                    last == null
                        ? ""
                        : _formatTime(
                            last['created_at']),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ConversationScreen(
                          conversationId:
                              conversation[
                                  'conversation_id'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}