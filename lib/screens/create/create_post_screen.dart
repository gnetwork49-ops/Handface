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
  State<CreatePostScreen> createState() =>
      _CreatePostScreenState();
}

class _CreatePostScreenState
    extends State<CreatePostScreen> {
  final TextEditingController _captionController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();

  final StorageService _storageService =
      StorageService();

  final PostService _postService =
      PostService();

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

  //----------------------------------
  // PICK IMAGE
  //----------------------------------

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
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

  //----------------------------------
  // PICK VIDEO
  //----------------------------------

  Future<void> _pickVideo() async {
    try {
      XFile? pickedVideo;

      if (kIsWeb) {
        final result =
            await FilePicker.platform.pickFiles(
          type: FileType.video,
          withData: true,
        );

        if (result == null) return;

        pickedVideo = XFile.fromData(
          result.files.first.bytes!,
          name: result.files.first.name,
          mimeType: "video/mp4",
        );

        print("VIDEO SELECTED");
        print(result.files.first.name);

        _videoController = null;
      } else {
        pickedVideo = await _picker.pickVideo(
          source: ImageSource.gallery,
        );

        if (pickedVideo == null) return;

        _videoController?.dispose();

        _videoController =
            VideoPlayerController.file(
          File(pickedVideo.path),
        );

        await _videoController!.initialize();

        _videoController!
          ..play()
          ..setLooping(true);
      }

      setState(() {
        _selectedVideo = pickedVideo;
        _selectedImage = null;
        _imageBytes = null;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  //----------------------------------
// PUBLISH POST
//----------------------------------

Future<void> _publishPost() async {
  if (_captionController.text.trim().isEmpty &&
      _selectedImage == null &&
      _selectedVideo == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Please add a caption, image or video.",
        ),
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

      print("Image uploaded.");
      print(imageUrl);
    }

    if (_selectedVideo != null) {
      print("Uploading video...");

      videoUrl = await _storageService.uploadPostVideo(
        _selectedVideo!,
      );

      print("Video uploaded.");
      print(videoUrl);
    }

    print("Saving post...");

    await _postService.createPost(
      caption: _captionController.text.trim(),
      imageUrl: imageUrl,
      videoUrl: videoUrl,
    );

    print("Post saved successfully.");

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
        content: Text(
          "Post published successfully!",
        ),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
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

          // IMAGE PREVIEW
          if (_selectedImage != null && _imageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _imageBytes!,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          // VIDEO PREVIEW (ANDROID)
          if (!kIsWeb &&
              _videoController != null &&
              _videoController!.value.isInitialized)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),

          // VIDEO SELECTED (WEB)
          if (kIsWeb && _selectedVideo != null)
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.videocam,
                      size: 70,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Video Selected",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _selectedVideo!.name,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          Row(
            children: [

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _pickImage,
                  icon: const Icon(Icons.photo),
                  label: const Text("Choose Image"),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _pickVideo,
                  icon: const Icon(Icons.videocam),
                  label: const Text("Choose Video"),
                ),
              ),

            ],
          ),

          const SizedBox(height: 25),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed:
                  _loading ? null : _publishPost,
              icon: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.publish),
              label: Text(
                _loading
                    ? "Publishing..."
                    : "Publish",
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}