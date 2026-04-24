import 'package:flutter_refresh_app/models/message.dart';
import 'package:share_plus/share_plus.dart';

abstract class MessageShareService {
  Future<void> share(Message message);
}

class SharePlusMessageShareService implements MessageShareService {
  @override
  Future<void> share(Message message) async {
    final String text = message.content;
    final String? imagePath = message.imagePath;
    if (imagePath == null || imagePath.isEmpty) {
      await Share.share(text);
      return;
    }

    await Share.shareXFiles(
      <XFile>[XFile(imagePath)],
      text: text,
    );
  }
}
