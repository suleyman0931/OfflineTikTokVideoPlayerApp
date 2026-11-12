import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_theme.dart';
import '../utils/app_settings.dart';
import '../widgets/video_grid_item.dart';
import '../widgets/tiktok_video_player.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: TextField(
          controller: _searchController,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search videos...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val.toLowerCase();
            });
          },
        ),
        elevation: 0,
      ),
      body: ValueListenableBuilder<List<File>>(
        valueListenable: AppSettings.allVideos,
        builder: (context, allVideos, child) {
          if (allVideos.isEmpty) {
            return Center(
              child: Text(
                'No videos available.',
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          final filteredVideos = allVideos.where((file) {
            final name = file.path.split('/').last.toLowerCase();
            return name.contains(_searchQuery);
          }).toList();

          if (filteredVideos.isEmpty) {
            return Center(
              child: Text(
                'No videos match your search.',
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 9 / 16,
            ),
            itemCount: filteredVideos.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Open scrollable library feed starting at tapped index
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => _LibraryVideoFeedScreen(
                        videos: filteredVideos,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: VideoGridItem(videoFile: filteredVideos[index]),
              );
            },
          );
        },
      ),
    );
  }
}

/// Full-screen TikTok-style scrollable feed for library videos
class _LibraryVideoFeedScreen extends StatefulWidget {
  final List<File> videos;
  final int initialIndex;

  const _LibraryVideoFeedScreen({
    required this.videos,
    required this.initialIndex,
  });

  @override
  State<_LibraryVideoFeedScreen> createState() => _LibraryVideoFeedScreenState();
}

class _LibraryVideoFeedScreenState extends State<_LibraryVideoFeedScreen> {
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
                itemCount: widget.videos.length,
                onPageChanged: (i) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentIndex = i);
                },
                itemBuilder: (context, index) {
                  return TikTokVideoPlayer(
                    key: ValueKey(widget.videos[index].path),
                    videoFile: widget.videos[index],
                    isActive: _currentIndex == index,
                    isAutoScrollEnabled: autoScrollEnabled,
                    onVideoEnded: () {
                      if (_currentIndex < widget.videos.length - 1) {
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
                  'Library',
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
                    '${_currentIndex + 1} / ${widget.videos.length}',
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
