import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================
  // Upload Profile Avatar
  // ==========================
  Future<String> uploadAvatar(XFile imageFile) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final bytes = await imageFile.readAsBytes();

    final extension =
        p.extension(imageFile.name.isNotEmpty ? imageFile.name : imageFile.path);

    final fileName =
        "${user.id}_${DateTime.now().millisecondsSinceEpoch}$extension";

    await _supabase.storage.from('avatars').uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );

    return _supabase.storage.from('avatars').getPublicUrl(fileName);
  }

  // ==========================
  // Upload Post Image
  // ==========================
  Future<String> uploadPostImage(XFile imageFile) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final bytes = await imageFile.readAsBytes();

    final extension =
        p.extension(imageFile.name.isNotEmpty ? imageFile.name : imageFile.path);

    final fileName =
        "${user.id}_${DateTime.now().millisecondsSinceEpoch}_image$extension";

    print("Uploading image...");
    print("File: $fileName");

    await _supabase.storage.from('posts').uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );

    final url = _supabase.storage.from('posts').getPublicUrl(fileName);

    print("Image uploaded.");
    print(url);

    return url;
  }

  // ==========================
  // Upload Post Video
  // ==========================
  Future<String> uploadPostVideo(XFile videoFile) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final bytes = await videoFile.readAsBytes();

    final extension =
        p.extension(videoFile.name.isNotEmpty ? videoFile.name : videoFile.path);

    final fileName =
        "${user.id}_${DateTime.now().millisecondsSinceEpoch}_video$extension";

    print("Uploading video...");
    print("File: $fileName");
    print("Bytes: ${bytes.length}");

    await _supabase.storage.from('videos').uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );

    final url = _supabase.storage.from('videos').getPublicUrl(fileName);

    print("Video uploaded.");
    print(url);

    return url;
  }

  // ==========================
  // Delete Image
  // ==========================
  Future<void> deleteImage(String url) async {
    final fileName = Uri.parse(url).pathSegments.last;

    await _supabase.storage.from('posts').remove([fileName]);
  }

  // ==========================
  // Delete Video
  // ==========================
  Future<void> deleteVideo(String url) async {
    final fileName = Uri.parse(url).pathSegments.last;

    await _supabase.storage.from('videos').remove([fileName]);
  }
}