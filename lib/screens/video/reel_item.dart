import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelItem extends StatefulWidget {
  final Map<String, dynamic> post;

  const ReelItem({
    super.key,
    required this.post,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _controller;

  bool _showPlay = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.post['video_url']),
    );

    _initialize();
  }

  Future<void> _initialize() async {
    await _controller.initialize();

    _controller
      ..setLooping(true)
      ..play();

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _showPlay = true;
    } else {
      _controller.play();
      _showPlay = false;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final profile = widget.post['profiles'];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [

          /// Video
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),

          /// Play Icon
          if (_showPlay)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 90,
              ),
            ),

          /// Bottom Gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black87,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          /// User Info
          Positioned(
            left: 16,
            bottom: 30,
            right: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "@${profile?['username'] ?? ''}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  widget.post['content'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          /// Right Buttons
          Positioned(
            right: 12,
            bottom: 40,
            child: Column(
              children: [

                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.favorite),
                ),

                const SizedBox(height: 20),

                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.comment),
                ),

                const SizedBox(height: 20),

                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.share),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}