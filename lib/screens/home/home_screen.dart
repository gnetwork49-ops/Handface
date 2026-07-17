import 'package:flutter/material.dart';

import '../create/create_post_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import 'feed_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    FeedScreen(),
    SearchScreen(),
    CreatePostScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: "Search",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: "Create",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_rounded),
            label: "Notifications",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}