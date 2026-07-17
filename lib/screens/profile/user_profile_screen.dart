import 'package:flutter/material.dart';

import '../../services/chat_service.dart';
import '../../services/follow_service.dart';
import '../../services/post_service.dart';
import '../../widgets/follow_button.dart';
import '../chat/conversation_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String? fullName;
  final String? username;
  final String? avatarUrl;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.fullName,
    this.username,
    this.avatarUrl,
  });

  @override
  State<UserProfileScreen> createState() =>
      _UserProfileScreenState();
}

class _UserProfileScreenState
    extends State<UserProfileScreen> {
  final FollowService _followService = FollowService();
  final PostService _postService = PostService();
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fullName ?? "Profile"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),

            CircleAvatar(
              radius: 55,
              backgroundImage: widget.avatarUrl != null &&
                      widget.avatarUrl!.isNotEmpty
                  ? NetworkImage(widget.avatarUrl!)
                  : null,
              child: widget.avatarUrl == null ||
                      widget.avatarUrl!.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 55,
                    )
                  : null,
            ),

            const SizedBox(height: 15),

            Text(
              widget.fullName ?? "Unknown User",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              "@${widget.username ?? ""}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            FutureBuilder<int>(
              future: _followService.followersCount(widget.userId),
              builder: (context, followersSnapshot) {
                return FutureBuilder<int>(
                  future: _followService.followingCount(widget.userId),
                  builder: (context, followingSnapshot) {
                    return Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              "${followersSnapshot.data ?? 0}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const Text("Followers"),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "${followingSnapshot.data ?? 0}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const Text("Following"),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: FollowButton(
                      userId: widget.userId,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                      ),
                      label: const Text("Message"),
                      onPressed: () async {
                        final conversationId =
                            await _chatService
                                .createOrGetConversation(
                          widget.userId,
                        );

                        if (!mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ConversationScreen(
                              conversationId:
                                  conversationId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Divider(),

            const Padding(
              padding: EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Posts",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: _postService.getUserPosts(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      snapshot.error.toString(),
                    ),
                  );
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: Text(
                        "No posts yet",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  itemCount: posts.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    if (post['image_url'] != null &&
                        post['image_url']
                            .toString()
                            .isNotEmpty) {
                      return ClipRRect(
                        borderRadius:
                            BorderRadius.circular(8),
                        child: Image.network(
                          post['image_url'],
                          fit: BoxFit.cover,
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.article,
                          size: 40,
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}