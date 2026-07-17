import 'package:flutter/material.dart';

import '../../services/post_service.dart';
import '../../widgets/post_card.dart';
import '../chat/chat_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostService _postService = PostService();

  late Future<List<Map<String, dynamic>>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    _postsFuture = _postService.getPosts();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadPosts();
    });

    await _postsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: false,
        title: const Text(
          "Handface",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Messages",
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  const SizedBox(height: 200),
                  Center(
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 220),
                  Center(
                    child: Text(
                      "No posts yet.\nCreate your first post!",
                      textAlign: TextAlign.center,
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                8,
                10,
                8,
                90,
              ),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                return PostCard(
                  key: ValueKey(posts[index]['id']),
                  post: posts[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}