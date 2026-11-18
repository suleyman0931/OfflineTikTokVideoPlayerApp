import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/app_theme.dart';
import '../utils/app_settings.dart';
import '../widgets/tiktok_video_player.dart';

class VideoFeedScreen extends StatefulWidget {
  final bool isTutorialActive;
  final bool isPipMode;

  const VideoFeedScreen(
      {super.key, this.isTutorialActive = false, this.isPipMode = false});

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _requestPermissionsAndLoadVideos();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissionsAndLoadVideos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (Platform.isAndroid) {
      bool permissionGranted = false;

      // Try requesting general storage first (works on Android 12 and below)
      var status = await Permission.storage.request();
      if (status.isGranted) {
        permissionGranted = true;
      } else {
        // On Android 13+, general storage is permanently denied by default,
        // so we must request granular video permissions instead.
        var videoStatus = await Permission.videos.request();
        if (videoStatus.isGranted) {
          permissionGranted = true;
        }
      }

      if (!permissionGranted) {
        _showPermissionDialog();
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }
    // Start background scan without awaiting
    AppSettings.loadAllVideos().then((_) {
      if (mounted && AppSettings.allVideos.value.isEmpty) {
        // If scan finishes and absolutely NO videos were found, stop loading screen
        setState(() => _isLoading = false);
      }
    });

    // Dismiss loading screen IMMEDIATELY as soon as the first video is found
    if (AppSettings.allVideos.value.isNotEmpty) {
      if (mounted) setState(() => _isLoading = false);
    } else {
      void onVideoFound() {
        if (AppSettings.allVideos.value.isNotEmpty && mounted) {
          setState(() => _isLoading = false);
          AppSettings.allVideos.removeListener(onVideoFound);
        }
      }

      AppSettings.allVideos.addListener(onVideoFound);
    }
  }

  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) return 33; // Mocking for newer API by default
    return 0;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Permission Required',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This app needs access to your videos to display them. Please enable the permission in Settings.',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(
              'Open Settings',
              style: GoogleFonts.inter(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_isLoading)
          const _BrandedLoader()
        else if (_errorMessage.isNotEmpty)
          _EmptyState(
            message: _errorMessage,
            onRescan: _requestPermissionsAndLoadVideos,
          )
        else
          ValueListenableBuilder<List<File>>(
            valueListenable: AppSettings.allVideos,
            builder: (context, allVideos, child) {
              if (allVideos.isEmpty) {
                return _EmptyState(
                  message: 'No videos found on your device.',
                  onRescan: _requestPermissionsAndLoadVideos,
                );
              }
              return ValueListenableBuilder<bool>(
                valueListenable: AppSettings.isAutoScrollEnabled,
                builder: (context, autoScrollEnabled, child) {
                  return PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: allVideos.length,
                    onPageChanged: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => _currentIndex = i);

                      // Check if last video
                      if (i == allVideos.length - 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                "You've reached the end of the feed!"),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppColors.surfaceAlt,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.only(
                                bottom: 70, left: 16, right: 16),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context, index) {
                      return TikTokVideoPlayer(
                        key: ValueKey(allVideos[index].path),
                        videoFile: allVideos[index],
                        isActive:
                            _currentIndex == index && !widget.isTutorialActive,
                        isAutoScrollEnabled: autoScrollEnabled,
                        isPipMode: widget.isPipMode,
                        onVideoEnded: () {
                          if (_currentIndex < allVideos.length - 1) {
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
              );
            },
          ),

        // Top edge drag absorber (allows pulling down Android notification bar without scrolling video)
        if (!_isLoading && !widget.isPipMode)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 60,
            child: GestureDetector(
              onVerticalDragUpdate: (_) {}, // Absorb vertical drags
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),

        // Top gradient scrim for status-bar readability
        if (!_isLoading && !widget.isPipMode)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 130,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

        // Top brand + counter (offset for menu button / notch)
        if (!_isLoading && !widget.isPipMode)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 10,
            left: 56,
            right: 168,
            child: Row(
              children: [
                Flexible(
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.brandGradient.createShader(bounds),
                    child: Text(
                      MediaQuery.sizeOf(context).width < 400
                          ? 'Offline Player'
                          : 'Offline TikTok Player',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize:
                            MediaQuery.sizeOf(context).width < 400 ? 15 : 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder<List<File>>(
                  valueListenable: AppSettings.allVideos,
                  builder: (context, allVideos, child) {
                    if (allVideos.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _GlassPill(
                        child: Text(
                          '${_currentIndex + 1} / ${allVideos.length}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Small reusable "frosted glass" UI pieces
class _GlassPill extends StatelessWidget {
  final Widget child;
  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _BrandedLoader extends StatefulWidget {
  const _BrandedLoader();

  @override
  State<_BrandedLoader> createState() => _BrandedLoaderState();
}

class _BrandedLoaderState extends State<_BrandedLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: Tween(begin: 0.92, end: 1.05).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Offline TikTok Player',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Loading your videos…',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onRescan;
  const _EmptyState({required this.message, required this.onRescan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.18),
                    AppColors.secondary.withOpacity(0.18),
                  ],
                ),
              ),
              child: const Icon(Icons.video_library_outlined,
                  color: Colors.white70, size: 42),
            ),
            const SizedBox(height: 24),
            Text(
              'No videos yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            _GradientButton(
              icon: Icons.refresh_rounded,
              label: 'Rescan for videos',
              onTap: onRescan,
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _GradientButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
