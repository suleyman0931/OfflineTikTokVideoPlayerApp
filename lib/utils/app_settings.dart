import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class AppSettings {
  static final ValueNotifier<bool> isAutoScrollEnabled = ValueNotifier(false);
  static final ValueNotifier<Set<String>> likedVideos = ValueNotifier({});
  static final ValueNotifier<Set<String>> savedVideos = ValueNotifier({});
  static final ValueNotifier<List<File>> allVideos = ValueNotifier([]);
  static final ValueNotifier<bool> isScanning = ValueNotifier(false);
  static final ValueNotifier<dynamic> pipActionNotifier = ValueNotifier(null);
  /// Local path to the user's uploaded profile photo, or null for default avatar.
  static final ValueNotifier<String?> userProfilePhotoPath = ValueNotifier(null);

  static bool _isListenerAdded = false;
  static bool _prefsLoaded = false;

  static Future<void> ensurePrefsLoaded() async {
    if (_prefsLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    likedVideos.value = (prefs.getStringList('liked_videos') ?? []).toSet();
    savedVideos.value = (prefs.getStringList('saved_videos') ?? []).toSet();
    final photo = prefs.getString('user_profile_photo');
    if (photo != null && File(photo).existsSync()) {
      userProfilePhotoPath.value = photo;
    }

    if (!_isListenerAdded) {
      likedVideos.addListener(() {
        prefs.setStringList('liked_videos', likedVideos.value.toList());
      });
      savedVideos.addListener(() {
        prefs.setStringList('saved_videos', savedVideos.value.toList());
      });
      userProfilePhotoPath.addListener(() {
        final path = userProfilePhotoPath.value;
        if (path == null) {
          prefs.remove('user_profile_photo');
        } else {
          prefs.setString('user_profile_photo', path);
        }
      });
      _isListenerAdded = true;
    }
    _prefsLoaded = true;
  }

  static void toggleLike(String path) {
    final likes = Set<String>.from(likedVideos.value);
    if (likes.contains(path)) {
      likes.remove(path);
    } else {
      likes.add(path);
    }
    likedVideos.value = likes;
  }

  static void toggleSave(String path) {
    final saved = Set<String>.from(savedVideos.value);
    if (saved.contains(path)) {
      saved.remove(path);
    } else {
      saved.add(path);
    }
    savedVideos.value = saved;
  }

  static bool isLiked(String path) => likedVideos.value.contains(path);
  static bool isSaved(String path) => savedVideos.value.contains(path);

  /// Opens the gallery so the user can set their own profile photo.
  static Future<bool> pickUserProfilePhoto() async {
    await ensurePrefsLoaded();
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return false;

    final docs = await getApplicationDocumentsDirectory();
    final dest = File('${docs.path}/user_profile.jpg');
    await File(picked.path).copy(dest.path);
    userProfilePhotoPath.value = dest.path;
    return true;
  }

  static Future<void> clearUserProfilePhoto() async {
    await ensurePrefsLoaded();
    final path = userProfilePhotoPath.value;
    if (path != null) {
      try {
        final f = File(path);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}
    }
    userProfilePhotoPath.value = null;
  }

  static Future<void> loadAllVideos() async {
    if (isScanning.value) return;
    isScanning.value = true;

    await ensurePrefsLoaded();

    List<File> videos = [];
    List<Directory> directoriesToScan = [Directory('/storage/emulated/0')];

    try {
      final extDirs = await getExternalStorageDirectories();
      if (extDirs != null) {
        for (var dir in extDirs) {
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
        final entities =
            await currentDir.list(recursive: false, followLinks: false).toList();
        entities.shuffle();
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

        if (addedNewVideo && (videos.length == 1 || videos.length % 10 == 0)) {
          allVideos.value = List.from(videos);
        }
      } catch (e) {
        continue;
      }
    }

    allVideos.value = List.from(videos);
    isScanning.value = false;
  }
}
