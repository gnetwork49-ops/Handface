import 'package:flutter/material.dart';

import '../services/post_service.dart';

class RepostButton extends StatefulWidget {
  final String postId;

  const RepostButton({
    super.key,
    required this.postId,
  });

  @override
  State<RepostButton> createState() => _RepostButtonState();
}

class _RepostButtonState extends State<RepostButton> {
  final PostService _postService = PostService();

  bool _reposted = false;
  int _count = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final reposted =
        await _postService.hasReposted(widget.postId);

    final count =
        await _postService.getRepostCount(widget.postId);

    if (!mounted) return;

    setState(() {
      _reposted = reposted;
      _count = count;
      _loading = false;
    });
  }

  Future<void> _toggleRepost() async {
    if (_loading) return;

    setState(() {
      _loading = true;
    });

    if (_reposted) {
      await _postService.removeRepost(widget.postId);

      _reposted = false;
      _count--;
    } else {
      await _postService.repost(widget.postId);

      _reposted = true;
      _count++;
    }

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _toggleRepost,
      icon: Icon(
        Icons.repeat,
        size: 20,
        color: _reposted ? Colors.green : null,
      ),
      label: Text(
        _count > 0 ? "$_count" : "Repost",
        style: TextStyle(
          color: _reposted ? Colors.green : null,
        ),
      ),
    );
  }
}