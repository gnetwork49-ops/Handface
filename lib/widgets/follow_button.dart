import 'package:flutter/material.dart';
import '../services/follow_service.dart';

class FollowButton extends StatefulWidget {
  final String userId;

  const FollowButton({
    super.key,
    required this.userId,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  final FollowService _followService = FollowService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _followService.isFollowing(widget.userId),
      builder: (context, snapshot) {
        final following = snapshot.data ?? false;

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                following ? Colors.grey : Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            if (following) {
              await _followService.unfollowUser(widget.userId);
            } else {
              await _followService.followUser(widget.userId);
            }

            setState(() {});
          },
          child: Text(
            following ? "Following" : "Follow",
          ),
        );
      },
    );
  }
}