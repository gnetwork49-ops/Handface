import 'package:flutter/material.dart';
import '../services/post_service.dart';

class LikeButton extends StatefulWidget {
  final String postId;

  const LikeButton({
    super.key,
    required this.postId,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  final PostService _postService = PostService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _postService.hasLiked(widget.postId),
      builder: (context, likedSnapshot) {
        final liked = likedSnapshot.data ?? false;

        return FutureBuilder<int>(
          future: _postService.getLikeCount(widget.postId),
          builder: (context, countSnapshot) {
            final count = countSnapshot.data ?? 0;

            return InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () async {
                if (liked) {
                  await _postService.unlikePost(widget.postId);
                } else {
                  await _postService.likePost(widget.postId);
                }

                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: liked ? Colors.red : Colors.grey,
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Like ($count)",
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
      },
    );
  }
}