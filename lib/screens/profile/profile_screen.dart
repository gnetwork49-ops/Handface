import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/profile_service.dart';
import '../../services/storage_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
final StorageService _storageService = StorageService();
final ImagePicker _picker = ImagePicker();


  late Future<Map<String, dynamic>?> _profileFuture;
  late Future<List<Map<String, dynamic>>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _profileFuture = _profileService.getMyProfile();
    _postsFuture = _profileService.getMyPosts();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });
  }
Future<void> _changeProfilePicture() async {
  try {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    final imageUrl = await _storageService.uploadAvatar(
      pickedFile,
    );

    await _profileService.updateAvatar(imageUrl);

    await _refresh();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile picture updated!"),
      ),
    );
  } catch (e) {
    debugPrint("UPLOAD ERROR: $e");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Upload failed: $e"),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileSnapshot.hasError) {
            return Center(
              child: Text(profileSnapshot.error.toString()),
            );
          }

          final profile = profileSnapshot.data;

          if (profile == null) {
            return const Center(
              child: Text("Profile not found"),
            );
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _postsFuture,
            builder: (context, postSnapshot) {
              if (postSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final posts = postSnapshot.data ?? [];

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  children: [

                    // Cover
                    Container(
                      height: 180,
                      color: Colors.deepPurple,
                    ),

                    Transform.translate(
                      offset: const Offset(0, -50),
                      child: Column(
                        children: [

         GestureDetector(
         onTap: _changeProfilePicture,
           child: CircleAvatar(
            radius: 55,
           backgroundImage:
           (profile['avatar_url'] != null &&
                profile['avatar_url'].toString().isNotEmpty)
            ? NetworkImage(profile['avatar_url'])
            : null,
               child: (profile['avatar_url'] == null ||
               profile['avatar_url'].toString().isEmpty)
               ? const Icon(
                 Icons.person,
            size: 55,
          )
        : null,
  ),
),

                          const SizedBox(height: 10),

                          Text(
                            profile['full_name'] ?? 'No Name',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "@${profile['username'] ?? ''}",
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              (profile['bio'] == null ||
                                      profile['bio'].toString().isEmpty)
                                  ? "No bio yet."
                                  : profile['bio'],
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const EditProfileScreen(),
                                ),
                              );

                              setState(() {
                                _loadData();
                              });
                            },
                            child: const Text("Edit Profile"),
                          ),

                          const SizedBox(height: 25),

                          const Divider(),

                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "My Posts",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          if (posts.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "You haven't posted anything yet.",
                              ),
                            ),

                          ...posts.map(
                            (post) => Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  post['content'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}