import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_theme.dart';

/// A beautiful first-time tutorial overlay that teaches users how to use the app.
/// Shows only on first launch, then never again.
class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialOverlay({super.key, required this.onComplete});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();

  /// Check if the tutorial has already been completed
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('tutorial_completed') ?? false);
  }

  /// Mark the tutorial as completed
  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
  }
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late final PageController _pageController;
  late final AnimationController _pulseController;

  final List<_TutorialStep> _steps = const [
    _TutorialStep(
      icon: Icons.swipe_vertical_rounded,
      title: 'Swipe to Browse',
      description: 'Swipe up or down to scroll\nthrough videos like TikTok',
      gradient: [Color(0xFF667EEA), Color(0xFF764BA2)],
    ),
    _TutorialStep(
      icon: Icons.touch_app_rounded,
      title: 'Tap to Pause',
      description: 'Single tap anywhere on the\nvideo to pause or resume',
      gradient: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
    ),
    _TutorialStep(
      icon: Icons.favorite_rounded,
      title: 'Double Tap to Like',
      description: 'Double tap on a video to like it\nor use the heart button on the right',
      gradient: [Color(0xFFFF2E63), Color(0xFFB0006E)],
    ),
    _TutorialStep(
      icon: Icons.auto_awesome_rounded,
      title: 'Auto Scroll',
      description: 'Enable auto-scroll from the menu\nto play videos one after another',
      gradient: [Color(0xFFF093FB), Color(0xFFF5576C)],
    ),
    _TutorialStep(
      icon: Icons.picture_in_picture_alt_rounded,
      title: 'Mini Screen',
      description: 'Swipe home to continue watching\nin a floating mini player',
      gradient: [Color(0xFF00C6FF), Color(0xFF0072FF)],
    ),
    _TutorialStep(
      icon: Icons.rocket_launch_rounded,
      title: 'You\'re All Set!',
      description: 'Enjoy watching your offline\nvideo collection',
      gradient: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeTutorial();
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  void _completeTutorial() async {
    await TutorialOverlay.markCompleted();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blurred dark background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withValues(alpha: 0.85),
              ),
            ),
          ),

          // Tutorial content
          SafeArea(
            child: Column(
              children: [
                // Skip button at top right
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: GestureDetector(
                      onTap: _skipTutorial,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Main tutorial slides
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentStep = index);
                    },
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      return _TutorialSlide(
                        step: _steps[index],
                        pulseController: _pulseController,
                      );
                    },
                  ),
                ),

                // Dots indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentStep == index ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentStep == index
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                ),

                // Next / Get Started button
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: GestureDetector(
                    onTap: _nextStep,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _steps[_currentStep].gradient,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: _steps[_currentStep]
                                .gradient[0]
                                .withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        _currentStep == _steps.length - 1
                            ? 'Get Started 🚀'
                            : 'Next',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
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

class _TutorialStep {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  const _TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

class _TutorialSlide extends StatelessWidget {
  final _TutorialStep step;
  final AnimationController pulseController;

  const _TutorialSlide({
    required this.step,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon in a glowing circle
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              final scale = 1.0 + (pulseController.value * 0.08);
              final glowOpacity = 0.15 + (pulseController.value * 0.15);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: step.gradient,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: step.gradient[0].withValues(alpha: glowOpacity),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: step.gradient[1].withValues(alpha: glowOpacity),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(
                    step.icon,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            step.title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),

          // Hand gesture animation hint for specific steps
          const SizedBox(height: 32),
          _buildGestureHint(),
        ],
      ),
    );
  }

  Widget _buildGestureHint() {
    // Show a subtle animated hand gesture icon for the first 3 steps
    switch (step.icon) {
      case Icons.swipe_vertical_rounded:
        return _GestureHintRow(
          icons: [Icons.arrow_upward_rounded, Icons.arrow_downward_rounded],
          label: 'Swipe up or down',
        );
      case Icons.touch_app_rounded:
        return const _GestureHintRow(
          icons: [Icons.touch_app_outlined],
          label: 'Tap once',
        );
      case Icons.favorite_rounded:
        return const _GestureHintRow(
          icons: [Icons.touch_app_outlined, Icons.touch_app_outlined],
          label: 'Tap twice quickly',
        );
      case Icons.picture_in_picture_alt_rounded:
        return const _GestureHintRow(
          icons: [Icons.swipe_up_rounded],
          label: 'Swipe up to Home',
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _GestureHintRow extends StatelessWidget {
  final List<IconData> icons;
  final String label;

  const _GestureHintRow({required this.icons, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...icons.map((icon) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(icon, color: Colors.white54, size: 20),
              )),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
