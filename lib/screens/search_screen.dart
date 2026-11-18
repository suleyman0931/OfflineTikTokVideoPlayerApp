import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_settings.dart';
import '../utils/app_theme.dart';
import '../widgets/video_grid_item.dart';
import 'library_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clear() {
    HapticFeedback.selectionClick();
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900 ? 6 : (width >= 600 ? 5 : 3);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14.5),
            decoration: InputDecoration(
              hintText: 'Search videos',
              hintStyle:
                  GoogleFonts.inter(color: Colors.white38, fontSize: 14.5),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Colors.white54, size: 21),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white54, size: 19),
                      onPressed: _clear,
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              setState(() => _query = value.trim().toLowerCase());
            },
          ),
        ),
        actions: const [SizedBox(width: 16)],
      ),
      body: ValueListenableBuilder<List<File>>(
        valueListenable: AppSettings.allVideos,
        builder: (context, allVideos, _) {
          if (allVideos.isEmpty) {
            return const _SearchEmptyState(
              icon: Icons.video_library_outlined,
              title: 'No videos found',
              message: 'No videos are available on your device yet.',
            );
          }

          final filtered = _query.isEmpty
              ? <File>[]
              : allVideos.where((file) {
                  final name = file.uri.pathSegments.last.toLowerCase();
                  return name.contains(_query);
                }).toList();

          if (_query.isEmpty) {
            return _SearchEmptyState(
              icon: Icons.search_rounded,
              title: 'Find a video',
              message:
                  'Search ${allVideos.length} videos by file name.\nResults appear here instantly.',
            );
          }

          if (filtered.isEmpty) {
            return _SearchEmptyState(
              icon: Icons.search_off_rounded,
              title: 'No results',
              message: 'No videos match "$_query".\nTry a different file name.',
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Text(
                  '${filtered.length} ${filtered.length == 1 ? 'result' : 'results'}',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.fromLTRB(
                    2,
                    0,
                    2,
                    2 + MediaQuery.paddingOf(context).bottom,
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    childAspectRatio: 9 / 16,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        FocusScope.of(context).unfocus();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LibraryVideoFeedScreen(
                              videos: filtered,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: VideoGridItem(videoFile: filtered[index]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _SearchEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.18),
                    AppColors.secondary.withOpacity(0.18),
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Icon(icon, color: Colors.white70, size: 36),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
