import 'package:flutter/material.dart';
import '../../services/comment_service.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({
    super.key,
    required this.postId,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final CommentService _commentService = CommentService();
  final TextEditingController _controller = TextEditingController();

  Future<void> _sendComment() async {
    if (_controller.text.trim().isEmpty) return;

    await _commentService.addComment(
      postId: widget.postId,
      comment: _controller.text.trim(),
    );

    _controller.clear();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _commentService.getComments(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return const Center(
                    child: Text("No comments yet"),
                  );
                }

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final profile = comment['profiles'];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profile != null &&
                                profile['avatar_url'] != null &&
                                profile['avatar_url']
                                    .toString()
                                    .isNotEmpty
                            ? NetworkImage(profile['avatar_url'])
                            : null,
                        child: profile == null ||
                                profile['avatar_url'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        profile?['full_name'] ?? "Unknown User",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(comment['comment']),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Write a comment...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _sendComment,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}