import 'package:flutter/material.dart';

import '../../services/post_service.dart';
import 'reel_item.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PostService _postService = PostService();

  final PageController _pageController = PageController();

  List<Map<String, dynamic>> _videos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final videos = await _postService.getVideoPosts();

      if (!mounted) return;

      setState(() {
        _videos = videos;
        _loading = false;
      });

      debugPrint("Loaded ${videos.length} reels");
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_videos.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "No Reels Yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        itemCount: _videos.length,
        onPageChanged: (index) {
          debugPrint("Current Reel: $index");
        },
        itemBuilder: (context, index) {
          return ReelItem(
            key: ValueKey(_videos[index]['id']),
            post: _videos[index],
          );
        },
      ),
    );
  }
}