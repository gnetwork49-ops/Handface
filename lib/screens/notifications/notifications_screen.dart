import 'package:flutter/material.dart';

import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  final NotificationService _notificationService =
      NotificationService();

  Future<void> _refresh() async {
    setState(() {});
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'follow':
        return Icons.person_add;
      case 'repost':
        return Icons.repeat;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'follow':
        return Colors.green;
      case 'repost':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getMessage(String type) {
    switch (type) {
      case 'like':
        return "liked your post ❤️";
      case 'comment':
        return "commented on your post 💬";
      case 'repost':
        return "reposted your post 🔁";
      case 'follow':
        return "started following you";
      default:
        return "sent you a notification";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 220),
                  Center(
                    child: Text(
                      "No notifications yet",
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
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification =
                    notifications[index];

                return ListTile(
                  onTap: () async {
                    if (notification['is_read'] != true) {
                      await _notificationService
                          .markAsRead(notification['id']);

                      setState(() {});
                    }
                  },

                  leading: Builder(
                    builder: (_) {
                      final profile =
                          notification['profiles'];

                      if (profile != null &&
                          profile['avatar_url'] != null &&
                          profile['avatar_url']
                              .toString()
                              .isNotEmpty) {
                        return CircleAvatar(
                          backgroundImage: NetworkImage(
                            profile['avatar_url'],
                          ),
                        );
                      }

                      return CircleAvatar(
                        backgroundColor: _getColor(
                          notification['type'],
                        ).withOpacity(.15),
                        child: Icon(
                          _getIcon(notification['type']),
                          color: _getColor(
                              notification['type']),
                        ),
                      );
                    },
                  ),

                  title: Builder(
                    builder: (_) {
                      final profile =
                          notification['profiles'];

                      final name = profile == null
                          ? "Someone"
                          : (profile['full_name'] ??
                              profile['username'] ??
                              "Someone");

                      return RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context)
                              .style
                              .copyWith(
                                fontWeight:
                                    notification['is_read'] ==
                                            true
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                              ),
                          children: [
                            TextSpan(
                              text: name,
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  " ${_getMessage(notification['type'])}",
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  subtitle: Text(
                    notification['created_at']
                        .toString(),
                  ),

                  trailing:
                      notification['is_read'] == true
                          ? null
                          : const Icon(
                              Icons.circle,
                              color: Colors.blue,
                              size: 10,
                            ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}