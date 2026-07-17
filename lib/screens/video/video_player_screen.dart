import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;

  @override
  bool get wantKeepAlive => true;

  Future<void> _loadVideo() async {
    await _controller?.dispose();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    await _controller!.initialize();

    await _controller!.setLooping(true);
    await _controller!.setVolume(1);

    await _controller!.play();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoUrl != widget.videoUrl) {
      _loadVideo();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_controller == null ||
        !_controller!.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
        } else {
          _controller!.play();
        }

        setState(() {});
      },
      child: Stack(
        fit: StackFit.expand,
        children: [

          /// Video
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),

          /// Play button
          if (!_controller!.value.isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}