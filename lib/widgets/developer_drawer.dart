import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import '../utils/app_settings.dart';

class DeveloperDrawer extends StatelessWidget {
  const DeveloperDrawer({super.key});

  Future<void> _launchTelegram(BuildContext context, String username) async {
    final url = Uri.parse('https://t.me/$username');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Telegram.')),
        );
      }
    }
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Phone app.')),
        );
      }
    }
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    final url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Email app.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: Drawer(
        backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Glassmorphism background
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                  Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/dev_bg.jpg'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Container(
                    // Inner container to darken the background image slightly so text is readable
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.transparent,
                            child: Icon(Icons.developer_mode_rounded, size: 36, color: Colors.white),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        'Development Team',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'If you want to have an app for your organization, contact us.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
                
                // Settings Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: AppSettings.isAutoScrollEnabled,
                      builder: (context, isEnabled, child) {
                        return SwitchListTile(
                          title: const Text('Auto-Scroll Videos', style: TextStyle(color: Colors.white)),
                          subtitle: const Text('Automatically scroll when video ends', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          value: isEnabled,
                          activeColor: AppColors.primary,
                          onChanged: (val) => AppSettings.isAutoScrollEnabled.value = val,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                
                // Developer Profile
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    'Developer Profile',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                // Suleyman Abdu
                _buildInfoTile(
                  context: context,
                  imagePath: 'assets/images/img_pfpuooh0.png',
                  title: 'Main Developer',
                  subtitle: 'Suleyman Abdu',
                  telegramUsername: 'suleyman_abdu',
                  phone: '0931798929',
                  email: 'suleymanabdu0931@gmail.com',
                  gradientColors: [Colors.blueAccent, Colors.cyanAccent],
                ),
                
                const Spacer(),
                
                // Footer (Services)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Our Services:\n• Mobile App Development\n• Web Application Development\n• Website Development\n• Desktop Applications',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Built with ❤️ using Flutter',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String subtitle,
    required String telegramUsername,
    required List<Color> gradientColors,
    String? phone,
    String? email,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: gradientColors[0].withOpacity(0.8), width: 2),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _launchTelegram(context, telegramUsername),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.send_rounded, color: Color(0xFF0088cc), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '@$telegramUsername',
                              style: const TextStyle(
                                color: Color(0xFF0088cc),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (phone != null) ...[
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _launchPhone(context, phone),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.phone_rounded, color: Colors.greenAccent, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                phone,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (email != null) ...[
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _launchEmail(context, email),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.email_rounded, color: Colors.orangeAccent, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  email,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
