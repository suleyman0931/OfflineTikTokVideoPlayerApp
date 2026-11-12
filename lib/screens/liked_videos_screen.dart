import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_theme.dart';
import '../utils/app_settings.dart';
import '../widgets/tiktok_video_player.dart';
import '../widgets/video_grid_item.dart';

class LikedVideosScreen extends StatelessWidget {
  const LikedVideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Liked Videos',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: AppSettings.likedVideos,
        builder: (context, likedSet, child) {
          if (likedSet.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, color: AppColors.primary, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No liked videos yet',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Double tap a video to like it.',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          final likedList = likedSet.toList().reversed.toList();
          
          return GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 9 / 16,
            ),
            itemCount: likedList.length,
            itemBuilder: (context, index) {
              final path = likedList[index];
              return GestureDetector(
                onTap: () {
                  // Open scrollable liked videos feed starting at tapped index
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LikedVideoFeedScreen(
                        likedPaths: likedList,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: VideoGridItem(videoFile: File(path)),
              );
            },
          );
        },
      ),
    );
  }
}

/// Full-screen TikTok-style scrollable feed for liked videos
class LikedVideoFeedScreen extends StatefulWidget {
  final List<String> likedPaths;
  final int initialIndex;

  const LikedVideoFeedScreen({
    super.key,
    required this.likedPaths,
    required this.initialIndex,
  });

  @override
  State<LikedVideoFeedScreen> createState() => _LikedVideoFeedScreenState();
}

class _LikedVideoFeedScreenState extends State<LikedVideoFeedScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: AppSettings.isAutoScrollEnabled,
            builder: (context, autoScrollEnabled, child) {
              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: widget.likedPaths.length,
                onPageChanged: (i) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentIndex = i);
                },
                itemBuilder: (context, index) {
                  return TikTokVideoPlayer(
                    key: ValueKey(widget.likedPaths[index]),
                    videoFile: File(widget.likedPaths[index]),
                    isActive: _currentIndex == index,
                    isAutoScrollEnabled: autoScrollEnabled,
                    onVideoEnded: () {
                      if (_currentIndex < widget.likedPaths.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  );
                },
              );
            },
          ),

          // Back button + counter overlay
          Positioned(
            top: 42,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Liked Videos',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.likedPaths.length}',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
