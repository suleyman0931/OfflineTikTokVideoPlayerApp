import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/thumbnail_helper.dart';

/// Pure visual thumbnail widget — no built-in navigation.
/// The parent widget should handle onTap.
class VideoGridItem extends StatefulWidget {
  final File videoFile;

  const VideoGridItem({super.key, required this.videoFile});

  @override
  State<VideoGridItem> createState() => _VideoGridItemState();
}

class _VideoGridItemState extends State<VideoGridItem> {
  String? _thumbnailPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    setState(() => _isLoading = true);
    final path = await ThumbnailHelper.getThumbnail(widget.videoFile.path);
    if (mounted) {
      setState(() {
        _thumbnailPath = path;
        _isLoading = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant VideoGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoFile.path != widget.videoFile.path) {
      _loadThumbnail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background/Thumbnail
        if (_isLoading)
          Container(color: Colors.white10)
        else if (_thumbnailPath != null)
          Image.file(
            File(_thumbnailPath!),
            fit: BoxFit.cover,
          )
        else
          Container(
            color: Colors.black45,
            child: const Icon(Icons.videocam_off, color: Colors.white54),
          ),
          
        // Play icon overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
            ),
          ),
        ),
        const Positioned(
          bottom: 6,
          left: 6,
          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}
