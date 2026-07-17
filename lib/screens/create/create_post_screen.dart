import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../services/post_service.dart';
import '../../services/storage_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController =
      TextEditingController();

  final PostService _postService = PostService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;
  XFile? _selectedVideo;

  Uint8List? _imageBytes;

  VideoPlayerController? _videoController;

  bool _loading = false;

  @override
  void dispose() {
    _captionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }
Future<void> _pickImage() async {
  final XFile? image = await _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );

  if (image == null) return;

  final bytes = await image.readAsBytes();

  _videoController?.dispose();

  setState(() {
    _selectedImage = image;
    _selectedVideo = null;
    _imageBytes = bytes;
    _videoController = null;
  });
}
Future<void> _pickVideo() async {
  try {
    XFile? pickedVideo;

    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        withData: true,
      );

      if (result == null) return;

      pickedVideo = XFile.fromData(
        result.files.first.bytes!,
        name: result.files.first.name,
      );

      print("Selected video: ${result.files.first.name}");
    } else {
      pickedVideo = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedVideo == null) return;
    }

    _selectedImage = null;
    _imageBytes = null;

    _videoController?.dispose();

    // Preview only on Android/iOS
    if (!kIsWeb) {
      _videoController = VideoPlayerController.file(
        File(pickedVideo.path),
      );

      await _videoController!.initialize();

      _videoController!
        ..setLooping(true)
        ..play();
    }

    setState(() {
      _selectedVideo = pickedVideo;
    });
  } catch (e) {
    debugPrint("Video picker error: $e");
  }
}

Future<void> _publishPost() async {
  if (_captionController.text.trim().isEmpty &&
      _selectedImage == null &&
      _selectedVideo == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please add a caption, image or video."),
      ),
    );
    return;
  }

  setState(() {
    _loading = true;
  });

  try {
    String? imageUrl;
    String? videoUrl;

    print("========== CREATE POST ==========");

    if (_selectedImage != null) {
      print("Uploading image...");

      imageUrl = await _storageService.uploadPostImage(
        _selectedImage!,
      );

      print("Image uploaded successfully.");
      print(imageUrl);
    }

    if (_selectedVideo != null) {
      print("Uploading video...");

      videoUrl = await _storageService.uploadPostVideo(
        _selectedVideo!,
      );

      print("Video uploaded successfully.");
      print(videoUrl);
    }

    print("Saving post to database...");

    await _postService.createPost(
      caption: _captionController.text.trim(),
      imageUrl: imageUrl,
      videoUrl: videoUrl,
    );

    print("Post saved successfully.");
    print("===============================");

    _captionController.clear();

    _videoController?.dispose();

    setState(() {
      _selectedImage = null;
      _selectedVideo = null;
      _imageBytes = null;
      _videoController = null;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Post published successfully!"),
      ),
    );
  } catch (e, stackTrace) {
    print("========== ERROR ==========");
    print(e);
    print(stackTrace);
    print("===========================");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _captionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            if (_imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _imageBytes!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            if (_videoController != null &&
                _videoController!
                    .value
                    .isInitialized)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio:
                      _videoController!
                          .value
                          .aspectRatio,
                  child: VideoPlayer(
                    _videoController!,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text(
                      "Choose Image",
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text(
                      "Choose Video",
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _loading ? null : _publishPost,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Publish"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}