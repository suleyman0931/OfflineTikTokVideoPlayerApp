import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailHelper {
  static bool _isProcessing = false;
  static final List<Function> _queue = [];

  static Future<String?> getThumbnail(String videoPath) async {
    final completer = Completer<String?>();
    
    _queue.add(() async {
      try {
        final tempDir = await getTemporaryDirectory();
        final fileName = 'thumb_${videoPath.hashCode}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        // Ensure path uniqueness
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: videoPath,
          thumbnailPath: '${tempDir.path}/$fileName',
          imageFormat: ImageFormat.JPEG,
          maxHeight: 250,
          quality: 75,
          timeMs: 1000,
        );
        completer.complete(thumbnailPath);
      } catch (e) {
        debugPrint('Error generating thumbnail: $e');
        completer.complete(null);
      }
    });

    _processQueue();
    return completer.future;
  }

  static Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;
    _isProcessing = true;
    
    while (_queue.isNotEmpty) {
      final task = _queue.removeAt(0);
      await task();
    }
    
    _isProcessing = false;
  }
}
