import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> sharePost({
    required String postId,
    required String caption,
  }) async {
    final text = '''
Check out this post on Handface 👇

$caption

https://handface.app/post/$postId
''';

    await SharePlus.instance.share(
      ShareParams(
        text: text,
      ),
    );
  }
}