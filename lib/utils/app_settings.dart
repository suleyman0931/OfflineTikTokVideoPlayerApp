import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class AppSettings {
  static final ValueNotifier<bool> isAutoScrollEnabled = ValueNotifier(false);
  static final ValueNotifier<Set<String>> likedVideos = ValueNotifier({});
  static final ValueNotifier<List<File>> allVideos = ValueNotifier([]);
  static final ValueNotifier<bool> isScanning = ValueNotifier(false);
  static final ValueNotifier<dynamic> pipActionNotifier = ValueNotifier(null);

  static bool _isListenerAdded = false;

  static Future<void> loadAllVideos() async {
    if (isScanning.value) return;
    isScanning.value = true;
    
    // Load liked videos
    final prefs = await SharedPreferences.getInstance();
    final savedLikes = prefs.getStringList('liked_videos') ?? [];
    likedVideos.value = savedLikes.toSet();

    if (!_isListenerAdded) {
      likedVideos.addListener(() {
        prefs.setStringList('liked_videos', likedVideos.value.toList());
      });
      _isListenerAdded = true;
    }
    
    List<File> videos = [];
    List<Directory> directoriesToScan = [Directory('/storage/emulated/0')];
    
    // Attempt to add external SD cards
    try {
      final extDirs = await getExternalStorageDirectories();
      if (extDirs != null) {
        for (var dir in extDirs) {
          // A path usually looks like /storage/XXXX-XXXX/Android/data/...
          // We extract the root /storage/XXXX-XXXX part
          final parts = dir.path.split('/');
          if (parts.length >= 3 && parts[1] == 'storage') {
            final sdCardRoot = '/storage/${parts[2]}';
            if (sdCardRoot != '/storage/emulated') {
              directoriesToScan.add(Directory(sdCardRoot));
            }
          }
        }
      }
    } catch (_) {}
    
    while (directoriesToScan.isNotEmpty) {
      final currentDir = directoriesToScan.removeLast();
      try {
        final entities = await currentDir.list(recursive: false, followLinks: false).toList();
        entities.shuffle(); // Randomize the feed!
        bool addedNewVideo = false;
        for (var entity in entities) {
          final path = entity.path;
          final name = path.split('/').last;

          if (name.startsWith('.') || name == 'Android') {
            continue;
          }

          if (entity is Directory) {
            directoriesToScan.add(entity);
          } else if (entity is File && path.toLowerCase().endsWith('.mp4')) {
            videos.add(entity);
            addedNewVideo = true;
          }
        }
        
        // Update the UI immediately if we found the first video, 
        // or periodically (every 10 videos) to avoid jank.
        if (addedNewVideo && (videos.length == 1 || videos.length % 10 == 0)) {
          allVideos.value = List.from(videos); // Notify listeners
        }
        
      } catch (e) {
        continue;
      }
    }

    // Update the final list once more just in case
    allVideos.value = List.from(videos);
    isScanning.value = false;
  }
}
