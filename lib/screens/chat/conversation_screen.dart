import 'package:flutter/material.dart';

import '../../services/chat_service.dart';
import '../../services/online_service.dart';

class ConversationScreen extends StatefulWidget {
  final String conversationId;

  const ConversationScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState
    extends State<ConversationScreen> {
  final ChatService _chatService = ChatService();
  final OnlineService _onlineService = OnlineService();

  final TextEditingController _controller =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTime(String? value) {
    if (value == null) return "";

    final date = DateTime.parse(value).toLocal();

    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
            ? 12
            : date.hour;

    final minute =
        date.minute.toString().padLeft(2, '0');

    final period =
        date.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $period";
  }

  String _lastSeen(String? value) {
    if (value == null) return "Offline";

    final lastSeen =
        DateTime.parse(value).toLocal();

    final diff =
        DateTime.now().difference(lastSeen);

    if (diff.inMinutes < 1) {
      return "Active now";
    }

    if (diff.inMinutes < 60) {
      return "Last seen ${diff.inMinutes} min ago";
    }

    if (diff.inHours < 24) {
      return "Last seen ${diff.inHours} hr ago";
    }

    return "Last seen ${diff.inDays} day(s) ago";
  }

  Future<void> _send() async {
    if (_controller.text.trim().isEmpty) return;

    await _chatService.sendMessage(
      conversationId: widget.conversationId,
      message: _controller.text.trim(),
    );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final me = _chatService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        elevation: 1,
        title: FutureBuilder<Map<String, dynamic>>(
          future: _chatService.getConversationUser(
            widget.conversationId,
          ),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Text("Conversation");
            }

            final user = snapshot.data!;

            return FutureBuilder<Map<String, dynamic>?>(
              future: _onlineService.getUserStatus(
                user['id'],
              ),
              builder: (context, statusSnapshot) {

                final status =
                    statusSnapshot.data;

                final online =
                    status?['is_online'] == true;

                return Row(
                  children: [

                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          user['avatar_url'] != null
                              ? NetworkImage(
                                  user['avatar_url'],
                                )
                              : null,
                      child:
                          user['avatar_url'] == null
                              ? const Icon(
                                  Icons.person,
                                )
                              : null,
                    ),

                    const SizedBox(width: 10),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [

                        Text(
                          user['full_name'] ??
                              "Unknown User",
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        Text(
                          online
                              ? "🟢 Active now"
                              : _lastSeen(
                                  status?[
                                      'last_seen'],
                                ),
                          style:
                              const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),

      body: Column(
        children: [

          // PART 2 goes here

        ],
      ),
    );
  }
}