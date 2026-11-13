import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/app_theme.dart';
import '../utils/app_settings.dart';
import 'video_controls_overlay.dart';
import 'package:simple_pip_mode/simple_pip.dart';

class TikTokVideoPlayer extends StatefulWidget {
  final File videoFile;
  final bool isActive;
  final bool isAutoScrollEnabled;
  final bool isPipMode;
  final VoidCallback? onVideoEnded;

  const TikTokVideoPlayer({
    super.key,
    required this.videoFile,
    required this.isActive,
    required this.isAutoScrollEnabled,
    this.isPipMode = false,
    this.onVideoEnded,
  });

  @override
  State<TikTokVideoPlayer> createState() => _TikTokVideoPlayerState();
}

class _TikTokVideoPlayerState extends State<TikTokVideoPlayer>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showPauseIcon = false;
  bool _showHeart = false;

  late final AnimationController _heartController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final Animation<double> _heartScale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.15), weight: 55),
    TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 45),
  ]).animate(CurvedAnimation(parent: _heartController, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(
      widget.videoFile,
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
    );
    
    AppSettings.pipActionNotifier.addListener(_onPipActionReceived);

    // Delay initialization slightly so that PageView scroll animations don't stutter
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _controller.initialize().then((_) {
        if (!mounted) return;
        setState(() => _isInitialized = true);
        _controller.setLooping(!widget.isAutoScrollEnabled);
        _controller.setVolume(1.0);
        
        _controller.addListener(_videoListener);

        if (widget.isActive) {
          _controller.play();
        }
      }).catchError((error) {
        debugPrint("Error loading video: $error");
        return null;
      });
    });
  }

  void _onPipActionReceived() {
    if (!mounted || !widget.isActive || !_isInitialized) return;
    
    final action = AppSettings.pipActionNotifier.value;
    if (action == null) return;
    
    final actionString = action.toString();
    
    if (actionString.contains('play')) {
      _controller.play();
      if (mounted) setState(() => _showPauseIcon = false);
    } else if (actionString.contains('pause')) {
      _controller.pause();
      if (mounted) setState(() => _showPauseIcon = true);
    }
  }

  void _videoListener() {
    if (!mounted || !_isInitialized) return;
    if (widget.isAutoScrollEnabled &&
        _controller.value.position >= _controller.value.duration &&
        _controller.value.duration > Duration.zero) {
      widget.onVideoEnded?.call();
    }
  }

  @override
  void didUpdateWidget(covariant TikTokVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInitialized) {
      if (widget.isActive && !oldWidget.isActive) {
        _controller.play();
        _showPauseIcon = false;
      } else if (!widget.isActive && oldWidget.isActive) {
        _controller.pause();
      }

      if (widget.isAutoScrollEnabled != oldWidget.isAutoScrollEnabled) {
        _controller.setLooping(!widget.isAutoScrollEnabled);
      }
    }
  }

  @override
  void dispose() {
    AppSettings.pipActionNotifier.removeListener(_onPipActionReceived);
    _controller.removeListener(_videoListener);
    _controller.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showPauseIcon = true;
      } else {
        _controller.play();
        _showPauseIcon = false;
      }
    });
    
    // Sync with OS Picture-in-Picture icon
    try {
      SimplePip().setIsPlaying(_controller.value.isPlaying);
    } catch (_) {}
  }

  void _toggleLikeOnly() {
    HapticFeedback.lightImpact();
    AppSettings.toggleLike(widget.videoFile.path);
  }

  void _toggleSave() {
    HapticFeedback.lightImpact();
    final wasSaved = AppSettings.isSaved(widget.videoFile.path);
    AppSettings.toggleSave(widget.videoFile.path);
    _showSnack(wasSaved ? 'Removed from saved' : 'Video saved');
  }

  Future<void> _onProfileTap() async {
    HapticFeedback.lightImpact();
    final ok = await AppSettings.pickUserProfilePhoto();
    if (ok && mounted) {
      _showSnack('Profile photo updated');
    }
  }

  void _onDoubleTap() {
    HapticFeedback.mediumImpact();
    setState(() => _showHeart = true);

    final path = widget.videoFile.path;
    if (!AppSettings.isLiked(path)) {
      AppSettings.toggleLike(path);
    }

    _heartController.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  String get _fileLabel {
    final name = widget.videoFile.uri.pathSegments.last;
    return name.length > 42 ? '${name.substring(0, 39)}…' : name;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.surfaceAlt,
      ),
    );
  }

  void _onShare() {
    Share.shareXFiles([XFile(widget.videoFile.path)], text: 'Check out this video!');
  }

  Future<void> _onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Video', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to permanently delete this video from your device?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Pause and stop the video before deleting
    if (_isInitialized) {
      _controller.pause();
    }

    try {
      // Check if file exists first
      if (!widget.videoFile.existsSync()) {
        _showSnack('Video file not found on disk.');
        _removeFromAppState();
        return;
      }

      // Try to delete
      widget.videoFile.deleteSync();
      _removeFromAppState();
      _showSnack('Video deleted successfully.');
    } on FileSystemException {
      // On Android 11+ scoped storage may block direct deletion
      // Try requesting MANAGE_EXTERNAL_STORAGE permission
      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.request();
        if (status.isGranted) {
          try {
            widget.videoFile.deleteSync();
            _removeFromAppState();
            _showSnack('Video deleted successfully.');
            return;
          } catch (_) {
            // Fall through to error message
          }
        }
      }
      if (mounted) {
        _showSnack(
          'Cannot delete: Android restricts file deletion. '
          'Please delete from your file manager app.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Could not delete video: $e');
      }
    }
  }

  void _removeFromAppState() {
    final videos = List<File>.from(AppSettings.allVideos.value);
    videos.removeWhere((v) => v.path == widget.videoFile.path);
    AppSettings.allVideos.value = videos;

    final likes = Set<String>.from(AppSettings.likedVideos.value);
    if (likes.remove(widget.videoFile.path)) {
      AppSettings.likedVideos.value = likes;
    }
    final saved = Set<String>.from(AppSettings.savedVideos.value);
    if (saved.remove(widget.videoFile.path)) {
      AppSettings.savedVideos.value = saved;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        // Background video layer
        _isInitialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              ),

        // Center tap for pause / double-tap like — kept clear of side actions
        Align(
          alignment: Alignment.center,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = (constraints.maxWidth * 0.55).clamp(160.0, 220.0);
              final h = (constraints.maxHeight * 0.45).clamp(220.0, 320.0);
              return GestureDetector(
                onTap: _togglePlayback,
                onDoubleTap: _onDoubleTap,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(width: w, height: h),
              );
            },
          ),
        ),

        // Side actions above the center tap so Like / Profile always receive taps
        if (_isInitialized && !widget.isPipMode)
          ValueListenableBuilder<Set<String>>(
            valueListenable: AppSettings.likedVideos,
            builder: (context, likedSet, _) {
              final isLiked = likedSet.contains(widget.videoFile.path);
              return ValueListenableBuilder<Set<String>>(
                valueListenable: AppSettings.savedVideos,
                builder: (context, savedSet, _) {
                  final isSaved = savedSet.contains(widget.videoFile.path);
                  return VideoControlsOverlay(
                    controller: _controller,
                    fileLabel: _fileLabel,
                    isLiked: isLiked,
                    isSaved: isSaved,
                    likeCount: isLiked ? 1 : 0,
                    onLike: _toggleLikeOnly,
                    onComment: () {
                      _showSnack('File: ${widget.videoFile.path}');
                    },
                    onSave: _toggleSave,
                    onShare: _onShare,
                    onDelete: _onDelete,
                    onProfileTap: _onProfileTap,
                  );
                },
              );
            },
          ),

        // Pause icon feedback
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: _showPauseIcon ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 46),
            ),
          ),
        ),

        // Double-tap heart burst
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: _showHeart ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: ScaleTransition(
              scale: _heartScale,
              child: const Icon(Icons.favorite_rounded,
                  color: AppColors.primary, size: 100),
            ),
          ),
        ),
      ],
    );
  }
}
