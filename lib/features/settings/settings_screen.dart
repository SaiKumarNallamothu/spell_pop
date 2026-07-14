import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'providers/settings_provider.dart';
import '../../shared/widgets/glass_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.displayMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AUDIO SECTION
              Text(
                'Audio & Sound',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingSwitchTile(
                      icon: Icons.music_note_rounded,
                      title: 'Background Music',
                      subtitle: 'Chilled background melodies',
                      value: settings.isMusicOn,
                      onChanged: (val) => settingsNotifier.toggleMusic(),
                      theme: theme,
                    ),
                    Divider(height: 1, color: theme.dividerColor.withOpacity(0.08)),
                    _buildSettingSwitchTile(
                      icon: Icons.volume_up_rounded,
                      title: 'Sound Effects',
                      subtitle: 'Sfx on button pops & correct answers',
                      value: settings.isSoundOn,
                      onChanged: (val) => settingsNotifier.toggleSound(),
                      theme: theme,
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.05, duration: 250.ms),

              const SizedBox(height: 24),

              // THEME & DISPLAY SECTION
              Text(
                'Appearance',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingSwitchTile(
                      icon: Icons.dark_mode_rounded,
                      title: 'Dark Theme Mode',
                      subtitle: 'Easier on the eyes at night',
                      value: settings.isDarkMode,
                      onChanged: (val) => settingsNotifier.toggleTheme(),
                      theme: theme,
                    ),
                    Divider(height: 1, color: theme.dividerColor.withOpacity(0.08)),
                    _buildSettingActionTile(
                      icon: Icons.translate_rounded,
                      title: 'Language',
                      subtitle: settings.language == 'en' ? 'English (US)' : settings.language,
                      onTap: () {
                        // Future proof locale selection dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Select Language'),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: const Text('English (US)'),
                                  trailing: settings.language == 'en' 
                                      ? Icon(Icons.check_circle, color: theme.colorScheme.primary) 
                                      : null,
                                  onTap: () {
                                    settingsNotifier.setLanguage('en');
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text('Spanish (Español) - Future'),
                                  onTap: () {
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

              // SYSTEM & LEGAL SECTION
              Text(
                'Support & About',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingActionTile(
                      icon: Icons.star_outline_rounded,
                      title: 'Rate App',
                      subtitle: 'Help us improve by leaving a review',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Rating redirection simulator'),
                            backgroundColor: theme.colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      theme: theme,
                    ),
                    Divider(height: 1, color: theme.dividerColor.withOpacity(0.08)),
                    _buildSettingActionTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'View how we secure offline records',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Privacy policy simulator'),
                            backgroundColor: theme.colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      theme: theme,
                    ),
                    Divider(height: 1, color: theme.dividerColor.withOpacity(0.08)),
                    _buildSettingActionTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About SpellPop',
                      subtitle: 'Version 1.0.0 (Offline Casual Mode)',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'SpellPop',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2026 SpellPop Dev Team. All rights reserved.',
                        );
                      },
                      theme: theme,
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.05, duration: 250.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.dividerColor.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
