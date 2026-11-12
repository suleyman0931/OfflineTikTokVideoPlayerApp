import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../utils/app_theme.dart';
import '../utils/constants.dart';

class VideoControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  final String fileLabel;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onInfo;
  final VoidCallback onDelete;
  
  const VideoControlsOverlay({
    super.key,
    required this.controller,
    required this.fileLabel,
    this.isLiked = false,
    required this.onLike,
    required this.onShare,
    required this.onInfo,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 60, 12, 12),
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
                // Left side: Text info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '@suleyman_abdu',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Watch this amazing local video! #tiktokclone #flutter $fileLabel',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.music_note_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Original Sound - Suleyman Abdu',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right side: Action Bar & Vinyl
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ProfileAvatar(),
                    const SizedBox(height: 10),
                    _ActionButton(
                      icon: Icons.favorite_rounded,
                      label: 'Like',
                      color: isLiked ? Colors.redAccent : Colors.white,
                      onTap: onLike,
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      icon: Icons.sms_rounded,
                      label: '4,021',
                      onTap: onInfo,
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      icon: Icons.bookmark_rounded,
                      label: '8,992',
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      icon: Icons.reply_rounded,
                      label: 'Share',
                      onTap: onShare,
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete',
                      onTap: onDelete,
                    ),
                    const SizedBox(height: 20),
                    const _SpinningVinyl(),
                    const SizedBox(height: 48),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Progress Bar at the very bottom
            _VideoProgressBar(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 60,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage(Constants.partnerPhotoAsset),
            ),
          ),
          Positioned(
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpinningVinyl extends StatefulWidget {
  const _SpinningVinyl();

  @override
  State<_SpinningVinyl> createState() => _SpinningVinylState();
}

class _SpinningVinylState extends State<_SpinningVinyl> with SingleTickerProviderStateMixin {
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
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 8),
          image: const DecorationImage(
            image: AssetImage(Constants.partnerPhotoAsset),
            fit: BoxFit.cover,
          ),
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
