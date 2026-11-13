import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../utils/app_settings.dart';
import '../utils/app_theme.dart';

class VideoControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  final String fileLabel;
  final bool isLiked;
  final bool isSaved;
  final int likeCount;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onProfileTap;

  const VideoControlsOverlay({
    super.key,
    required this.controller,
    required this.fileLabel,
    this.isLiked = false,
    this.isSaved = false,
    this.likeCount = 0,
    required this.onLike,
    required this.onComment,
    required this.onSave,
    required this.onShare,
    required this.onDelete,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    // Scale UI for short/tall phones (rough baseline ~800 logical height).
    final scale = (size.height / 800).clamp(0.72, 1.05);
    final gap = 4.0 * scale;
    final iconSize = 28.0 * scale;
    final avatarR = 20.0 * scale;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 48 * scale, 8, 8 + bottomPad * 0.15),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black87],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '@you',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      Text(
                        fileLabel,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13 * scale,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8 * scale),
                      Row(
                        children: [
                          Icon(Icons.music_note_rounded,
                              color: Colors.white, size: 14 * scale),
                          SizedBox(width: 6 * scale),
                          Expanded(
                            child: Text(
                              'Original Sound',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12 * scale,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8 * scale),
                    ],
                  ),
                ),
                SizedBox(width: 8 * scale),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ProfileAvatar(
                      radius: avatarR,
                      onTap: onProfileTap,
                    ),
                    SizedBox(height: gap),
                    _ActionButton(
                      icon: isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      label: likeCount > 0 ? _formatCount(likeCount) : 'Like',
                      color: isLiked ? Colors.redAccent : Colors.white,
                      iconSize: iconSize,
                      scale: scale,
                      onTap: onLike,
                    ),
                    SizedBox(height: gap),
                    _ActionButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Info',
                      iconSize: iconSize,
                      scale: scale,
                      onTap: onComment,
                    ),
                    SizedBox(height: gap),
                    _ActionButton(
                      icon: isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      label: isSaved ? 'Saved' : 'Save',
                      color: isSaved ? Colors.amberAccent : Colors.white,
                      iconSize: iconSize,
                      scale: scale,
                      onTap: onSave,
                    ),
                    SizedBox(height: gap),
                    _ActionButton(
                      icon: Icons.reply_rounded,
                      label: 'Share',
                      iconSize: iconSize,
                      scale: scale,
                      onTap: onShare,
                    ),
                    SizedBox(height: gap),
                    _ActionButton(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete',
                      iconSize: iconSize,
                      scale: scale,
                      onTap: onDelete,
                    ),
                    SizedBox(height: 12 * scale),
                    _SpinningVinyl(size: 36 * scale),
                    SizedBox(height: 8 * scale),
                  ],
                ),
              ],
            ),
            _VideoProgressBar(controller: controller),
          ],
        ),
      ),
    );
  }

  static String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _ProfileAvatar extends StatelessWidget {
  final double radius;
  final VoidCallback onTap;

  const _ProfileAvatar({required this.radius, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: radius * 2.2,
        height: radius * 2.6,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ValueListenableBuilder<String?>(
              valueListenable: AppSettings.userProfilePhotoPath,
              builder: (context, path, _) {
                final ImageProvider image = (path != null && File(path).existsSync())
                    ? FileImage(File(path))
                    : const AssetImage('assets/images/img_pfpuooh0.png')
                        as ImageProvider;
                return Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: radius,
                    backgroundImage: image,
                  ),
                );
              },
            ),
            Positioned(
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: Colors.white, size: radius * 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpinningVinyl extends StatefulWidget {
  final double size;
  const _SpinningVinyl({this.size = 40});

  @override
  State<_SpinningVinyl> createState() => _SpinningVinylState();
}

class _SpinningVinylState extends State<_SpinningVinyl>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: child,
        );
      },
      child: ValueListenableBuilder<String?>(
        valueListenable: AppSettings.userProfilePhotoPath,
        builder: (context, path, _) {
          final ImageProvider image = (path != null && File(path).existsSync())
              ? FileImage(File(path))
              : const AssetImage('assets/images/img_pfpuooh0.png')
                  as ImageProvider;
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: widget.size * 0.2),
              image: DecorationImage(image: image, fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}

class _VideoProgressBar extends StatelessWidget {
  final VideoPlayerController controller;

  const _VideoProgressBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return VideoProgressIndicator(
      controller,
      allowScrubbing: true,
      colors: VideoProgressColors(
        playedColor: Colors.white,
        bufferedColor: Colors.white.withOpacity(0.4),
        backgroundColor: Colors.white.withOpacity(0.2),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double iconSize;
  final double scale;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color = Colors.white,
    required this.iconSize,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 2 * scale,
            horizontal: 4 * scale,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: iconSize),
              SizedBox(height: 2 * scale),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
