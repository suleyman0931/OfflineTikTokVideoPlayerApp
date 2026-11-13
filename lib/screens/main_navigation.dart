import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_pip_mode/pip_widget.dart';
import 'package:simple_pip_mode/simple_pip.dart';
import 'package:simple_pip_mode/actions/pip_actions_layout.dart';

import '../utils/app_theme.dart';
import '../utils/app_settings.dart';
import 'video_feed_screen.dart';
import 'library_screen.dart';
import 'liked_videos_screen.dart';
import 'profile_screen.dart';
import '../widgets/developer_drawer.dart';
import '../widgets/tutorial_overlay.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _showTutorial = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _videoFeedKey = GlobalKey(); // Preserves state during PiP mode switches
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _checkTutorial();
    
    // Enable auto Picture-in-Picture mode on supported devices (Android 12+)
    try {
      SimplePip().setAutoPipMode().catchError((_) {
        // Ignore error on older Android versions (pre-Android 12)
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkTutorial() async {
    final shouldShow = await TutorialOverlay.shouldShow();
    if (shouldShow && mounted) {
      setState(() => _showTutorial = true);
    }
  }

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PipWidget(
      pipLayout: PipActionsLayout.mediaOnlyPause,
      onPipAction: (action) {
        AppSettings.pipActionNotifier.value = action;
        Future.delayed(Duration.zero, () => AppSettings.pipActionNotifier.value = null);
      },
      pipChild: Scaffold(
        backgroundColor: Colors.black,
        body: VideoFeedScreen(key: _videoFeedKey, isPipMode: true),
      ),
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          
          final now = DateTime.now();
          if (_lastBackPressTime == null ||
              now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
            _lastBackPressTime = now;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Press back again to exit'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.bg,
          drawer: const DeveloperDrawer(),
          body: Stack(
            children: [
              // IndexedStack keeps all screens alive — no reload when switching tabs
              IndexedStack(
                index: _currentIndex,
                children: [
                  VideoFeedScreen(key: _videoFeedKey, isTutorialActive: _showTutorial),
                  const LibraryScreen(),
                  const LibraryScreen(),
                  const LikedVideosScreen(),
                  const ProfileScreen(),
                ],
              ),
              if (_currentIndex == 0) ...[
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  left: 12,
                  child: _GlassIconButton(
                    icon: Icons.menu_rounded,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  right: 12,
                  child: _GlassIconButton(
                    icon: Icons.picture_in_picture_alt_rounded,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      try {
                        SimplePip().enterPipMode();
                      } catch (_) {}
                    },
                  ),
                ),
              ],

              // First-time tutorial overlay
              if (_showTutorial)
                TutorialOverlay(
                  onComplete: () {
                    setState(() => _showTutorial = false);
                  },
                ),
            ],
          ),
          bottomNavigationBar: Container(
            color: Colors.black,
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom > 0 ? 4 : 24,
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.sizeOf(context).width < 360 ? 4 : 12,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomNavItem(
                      icon: Icons.home_filled,
                      label: 'Home',
                      isActive: _currentIndex == 0,
                      onTap: () => _onItemTapped(0),
                    ),
                    _BottomNavItem(
                      icon: Icons.video_library_rounded,
                      label: 'Library',
                      isActive: _currentIndex == 1,
                      onTap: () => _onItemTapped(1),
                    ),
                    GestureDetector(
                      onTap: () => _onItemTapped(2),
                      child: Container(
                        height: 30,
                        width: 44,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.cyanAccent,
                              offset: Offset(-3, 0),
                            ),
                            BoxShadow(
                              color: Colors.redAccent,
                              offset: Offset(3, 0),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.black, size: 22),
                      ),
                    ),
                    _BottomNavItem(
                      icon: Icons.favorite_outline_rounded,
                      label: 'Liked',
                      isActive: _currentIndex == 3,
                      onTap: () => _onItemTapped(3),
                    ),
                    _BottomNavItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Profile',
                      isActive: _currentIndex == 4,
                      onTap: () => _onItemTapped(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.white54,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withOpacity(0.12),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.15)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
