import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../screens/profile/user_profile_screen.dart';
import '../screens/video/reels_screen.dart';

import 'like_button.dart';
import 'comment_button.dart';
import 'repost_button.dart';
import '../services/share_service.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    final String? videoUrl =
        widget.post['video_url'];

    if (videoUrl != null &&
        videoUrl.isNotEmpty) {
      _videoController =
          VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      _videoController!
          .initialize()
          .then((_) {
        _videoController!
          ..setLooping(true)
  ..setVolume(0);

        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
  @override
Widget build(BuildContext context) {
  final profile = widget.post['profiles'];

  return Container(
    margin: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // USER HEADER
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(
                      userId: profile?['id'] ?? '',
                      fullName: profile?['full_name'],
                      username: profile?['username'],
                      avatarUrl: profile?['avatar_url'],
                    ),
                  ),
                );
              },
              child: Row(
                children: [

                  CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        profile != null &&
                                profile['avatar_url'] != null &&
                                profile['avatar_url']
                                    .toString()
                                    .isNotEmpty
                            ? NetworkImage(
                                profile['avatar_url'],
                              )
                            : null,
                    child:
                        profile == null ||
                                profile['avatar_url'] == null ||
                                profile['avatar_url']
                                    .toString()
                                    .isEmpty
                            ? const Icon(Icons.person)
                            : null,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          profile?['full_name'] ??
                              "Unknown User",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),

                        Text(
                          "@${profile?['username'] ?? ""}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.more_horiz),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // CAPTION
            if (widget.post['content'] != null &&
                widget.post['content']
                    .toString()
                    .trim()
                    .isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 15),
                child: Text(
                  widget.post['content'],
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),

            // IMAGE
            if (widget.post['image_url'] != null &&
                widget.post['image_url']
                    .toString()
                    .isNotEmpty)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(14),
                child: Image.network(
                  widget.post['image_url'],
                  width: double.infinity,
                  height: 320,
                  fit: BoxFit.cover,
                ),
              ),

  // VIDEO
if (widget.post['video_url'] != null &&
    widget.post['video_url'].toString().isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(top: 10),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ReelsScreen(),
    ),
  );
},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          alignment: Alignment.center,
          children: [

            if (_videoController != null &&
                _videoController!.value.isInitialized)
              AspectRatio(
                aspectRatio:
                    _videoController!.value.aspectRatio,
                child: VideoPlayer(
                  _videoController!,
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.black12,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(35),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 42,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
            const SizedBox(height: 15),

            Divider(
              color: Colors.grey.shade300,
            ),
                        Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [

                LikeButton(
                  postId: widget.post['id'].toString(),
                ),

                CommentButton(
                  postId: widget.post['id'].toString(),
                ),

                RepostButton(
  postId: widget.post['id'].toString(),
),
TextButton.icon(
  onPressed: () async {
    await ShareService.sharePost(
      postId: widget.post['id'],
      caption: widget.post['content'] ?? '',
    );
  },
  icon: const Icon(
    Icons.share_outlined,
    size: 20,
  ),
  label: const Text("Share"),
),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}