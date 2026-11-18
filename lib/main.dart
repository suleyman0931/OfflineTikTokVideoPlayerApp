import 'package:flutter/material.dart';

import 'screens/main_navigation.dart';
import 'utils/app_settings.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.ensurePrefsLoaded();
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
