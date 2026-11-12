import 'package:flutter/material.dart';

import 'screens/main_navigation.dart';
import 'utils/app_theme.dart';
void main() {
  runApp(const OfflineTikTokPlayer());
}

class OfflineTikTokPlayer extends StatelessWidget {
  const OfflineTikTokPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tiktok video player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigation(),
    );
  }
}
