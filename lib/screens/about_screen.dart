import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_theme.dart';
import '../utils/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _email = 'suleymanabdu0931@gmail.com';
  static const String _phone = '0931798929';
  static const String _altPhone = '0915260722';
  static const String _github = 'suleyman0931';
  static const String _telegram = 'suleyman_abdu';
  static const Color _telegramColor = Color(0xFF229ED9);
  static const Color _githubColor = Color(0xFFE6E6F0);

  Future<void> _launch(BuildContext context, String url) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showSnack(context, 'Could not open the link.');
      }
    } catch (_) {
      if (context.mounted) _showSnack(context, 'Could not open the link.');
    }
  }

  void _showSnack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceAlt,
        content: Text(text, style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.width >= 700;
    final horizontal = size.width < 400 ? 16.0 : (isTablet ? 32.0 : 20.0);
    final avatarRadius = isTablet ? 56.0 : 46.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'About & Settings',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(
                    avatarRadius: avatarRadius,
                    isTablet: isTablet,
                    onEmail: () => _launch(context, 'mailto:$_email'),
                    onCall: () => _launch(context, 'tel:$_phone'),
                    onTelegram: () => _launch(context, 'https://t.me/$_telegram'),
                    onGithub: () => _launch(context, 'https://github.com/$_github'),
                  ),
                  const SizedBox(height: 30),
                  const _SectionLabel('CONTACT'),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final twoColumns = constraints.maxWidth >= 600;
                      final cardWidth = twoColumns
                          ? (constraints.maxWidth - 12) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: _ContactCard(
                              icon: Icons.mail_rounded,
                              iconColor: AppColors.secondary,
                              title: 'Email',
                              subtitle: _email,
                              onTap: () => _launch(context, 'mailto:$_email'),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _ContactCard(
                              icon: Icons.call_rounded,
                              iconColor: AppColors.primary,
                              title: 'Phone',
                              subtitle: _phone,
                              onTap: () => _launch(context, 'tel:$_phone'),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _ContactCard(
                              icon: Icons.phone_iphone_rounded,
                              iconColor: AppColors.primary,
                              title: 'Phone (Alternative)',
                              subtitle: _altPhone,
                              onTap: () => _launch(context, 'tel:$_altPhone'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const _SectionLabel('SOCIALS'),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final twoColumns = constraints.maxWidth >= 600;
                      final cardWidth = twoColumns
                          ? (constraints.maxWidth - 12) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: _ContactCard(
                              icon: Icons.code_rounded,
                              iconColor: _githubColor,
                              title: 'GitHub',
                              subtitle: 'github.com/$_github',
                              onTap: () => _launch(context, 'https://github.com/$_github'),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _ContactCard(
                              icon: Icons.send_rounded,
                              iconColor: _telegramColor,
                              title: 'Telegram',
                              subtitle: '@$_telegram',
                              onTap: () => _launch(context, 'https://t.me/$_telegram'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const _SectionLabel('PARTNERSHIP'),
                  const SizedBox(height: 12),
                  _PartnershipCard(
                    onCall: () => _launch(context, 'tel:$_phone'),
                    onTelegram: () => _launch(context, 'https://t.me/$_telegram'),
                  ),
                  const SizedBox(height: 36),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.06)),
                          ),
                          child: Text(
                            'Offline TikTok Player  •  v1.0.0',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Built with Flutter',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final double avatarRadius;
  final bool isTablet;
  final VoidCallback onEmail;
  final VoidCallback onCall;
  final VoidCallback onTelegram;
  final VoidCallback onGithub;

  const _ProfileHeader({
    required this.avatarRadius,
    required this.isTablet,
    required this.onEmail,
    required this.onCall,
    required this.onTelegram,
    required this.onGithub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32 : 20,
        isTablet ? 32 : 26,
        isTablet ? 32 : 20,
        isTablet ? 28 : 22,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF20202D), AppColors.surface],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.10),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: AppColors.surface,
              backgroundImage: const AssetImage(Constants.developerPhotoAsset),
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            'Suleyman Abdu',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isTablet ? 24 : 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.24)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.primary, size: 13),
                const SizedBox(width: 5),
                Text(
                  'App Developer',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickAction(
                icon: Icons.mail_rounded,
                label: 'Email',
                color: AppColors.secondary,
                onTap: onEmail,
              ),
              _QuickAction(
                icon: Icons.call_rounded,
                label: 'Call',
                color: AppColors.primary,
                onTap: onCall,
              ),
              _QuickAction(
                icon: Icons.send_rounded,
                label: 'Telegram',
                color: AboutScreen._telegramColor,
                onTap: onTelegram,
              ),
              _QuickAction(
                icon: Icons.code_rounded,
                label: 'GitHub',
                color: AboutScreen._githubColor,
                onTap: onGithub,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                color: Colors.white.withOpacity(0.3),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartnershipCard extends StatelessWidget {
  final VoidCallback onCall;
  final VoidCallback onTelegram;

  const _PartnershipCard({
    required this.onCall,
    required this.onTelegram,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.16),
            AppColors.secondary.withOpacity(0.16),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.handshake_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Orders & Collaboration',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Want to order a custom app or partner up? Reach out any time.',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    gradient: AppColors.brandGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.surface,
                    backgroundImage: AssetImage(Constants.developerPhotoAsset),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suleyman Abdu',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Developer',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _CircleAction(
                  icon: Icons.call_rounded,
                  color: AppColors.primary,
                  tooltip: 'Call',
                  onTap: onCall,
                ),
                const SizedBox(width: 8),
                _CircleAction(
                  icon: Icons.send_rounded,
                  color: AboutScreen._telegramColor,
                  tooltip: 'Telegram',
                  onTap: onTelegram,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.15),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 19),
          ),
        ),
      ),
    );
  }
}
