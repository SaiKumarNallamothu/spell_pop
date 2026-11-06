import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'providers/settings_provider.dart';
import '../../shared/widgets/glass_card.dart';
import '../../app/theme/theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. AUDIO & SOUND
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Sound & Music',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),

              GlassCard(
                padding: EdgeInsets.zero,
                backgroundColor: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                borderRadius: BorderRadius.circular(26),
                child: Column(
                  children: [
                    _buildSettingSwitchTile(
                      icon: Icons.music_note_rounded,
                      iconColor: AppTheme.primaryColor,
                      title: 'Background Music',
                      subtitle: 'Upbeat melodies and cheerful beats',
                      value: settings.isMusicOn,
                      onChanged: (val) => settingsNotifier.toggleMusic(),
                      theme: theme,
                    ),
                    Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 20,
                      color: theme.dividerColor.withValues(alpha: 0.08),
                    ),
                    _buildSettingSwitchTile(
                      icon: Icons.volume_up_rounded,
                      iconColor: AppTheme.coralPink,
                      title: 'Sound Effects (SFX)',
                      subtitle: 'Tile pops, cheers, and feedback sounds',
                      value: settings.isSoundOn,
                      onChanged: (val) => settingsNotifier.toggleSound(),
                      theme: theme,
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.05, duration: 250.ms),

              const SizedBox(height: 24),

              // 2. APPEARANCE
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Appearance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),

              GlassCard(
                padding: EdgeInsets.zero,
                backgroundColor: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                borderRadius: BorderRadius.circular(26),
                child: Column(
                  children: [
                    _buildSettingSwitchTile(
                      icon: Icons.dark_mode_rounded,
                      iconColor: AppTheme.sunnyYellow,
                      title: 'Dark Theme Mode',
                      subtitle: 'Deep midnight palette for low-light play',
                      value: settings.isDarkMode,
                      onChanged: (val) => settingsNotifier.toggleTheme(),
                      theme: theme,
                    ),
                    Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 20,
                      color: theme.dividerColor.withValues(alpha: 0.08),
                    ),
                    _buildSettingActionTile(
                      icon: Icons.translate_rounded,
                      iconColor: AppTheme.tealAccent,
                      title: 'Language',
                      subtitle: settings.language == 'en' ? 'English (US)' : settings.language,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Select Language'),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: const Text('English (US)'),
                                  trailing: settings.language == 'en'
                                      ? const Icon(Icons.check_circle_rounded, color: AppTheme.mintGreen)
                                      : null,
                                  onTap: () {
                                    settingsNotifier.setLanguage('en');
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      theme: theme,
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.05, duration: 250.ms),

              const SizedBox(height: 24),

              // 3. ABOUT & SUPPORT
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'About & Support',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),

              GlassCard(
                padding: EdgeInsets.zero,
                backgroundColor: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                borderRadius: BorderRadius.circular(26),
                child: Column(
                  children: [
                    _buildSettingActionTile(
                      icon: Icons.star_rate_rounded,
                      iconColor: AppTheme.sunnyYellow,
                      title: 'Rate Spell Pop',
                      subtitle: 'Show love and support future updates',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Thank you for loving Spell Pop! ❤️'),
                            backgroundColor: AppTheme.mintGreen,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      },
                      theme: theme,
                    ),
                    Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 20,
                      color: theme.dividerColor.withValues(alpha: 0.08),
                    ),
                    _buildSettingActionTile(
                      icon: Icons.privacy_tip_rounded,
                      iconColor: AppTheme.primaryGradientEnd,
                      title: 'Privacy Policy',
                      subtitle: 'Offline-first, safe for kids & adults',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('100% offline privacy safe.'),
                            backgroundColor: AppTheme.primaryColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      },
                      theme: theme,
                    ),
                    Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 20,
                      color: theme.dividerColor.withValues(alpha: 0.08),
                    ),
                    _buildSettingActionTile(
                      icon: Icons.info_rounded,
                      iconColor: AppTheme.mintGreen,
                      title: 'Spell Pop Version',
                      subtitle: 'v1.0.0 (2025 Edition)',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Spell Pop',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2025 Spell Pop Studio. All rights reserved.',
                        );
                      },
                      theme: theme,
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.05, duration: 250.ms),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.dividerColor.withValues(alpha: 0.4),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
