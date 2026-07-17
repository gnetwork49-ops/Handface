import 'package:flutter/material.dart';

import '../services/comment_service.dart';
import '../screens/comments/comments_screen.dart';

class CommentButton extends StatefulWidget {
  final String postId;

  const CommentButton({
    super.key,
    required this.postId,
  });

  @override
  State<CommentButton> createState() => _CommentButtonState();
}

class _CommentButtonState extends State<CommentButton> {
  final CommentService _commentService = CommentService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _commentService.getCommentCount(widget.postId),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommentsScreen(
                  postId: widget.postId,
                ),
              ),
            ).then((_) => setState(() {}));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  "Comment ($count)",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}