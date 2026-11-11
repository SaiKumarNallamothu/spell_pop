import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/providers/game_state.dart';
import '../settings/providers/settings_provider.dart';
import '../../shared/widgets/pop_button.dart';
import '../../shared/widgets/coin_balance_pill.dart';
import '../../app/theme/theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final gameState = ref.watch(gameStateProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient pastel background decorative circles
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppTheme.primaryColor.withValues(alpha: 0.15)
                    : AppTheme.pastelLavender,
              ),
            ),
          ),
          Positioned(
            top: 240,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppTheme.coralPink.withValues(alpha: 0.08)
                    : AppTheme.pastelPeach,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TOP APP BAR / USER STATUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Friendly Game Logo Badge
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryColor, AppTheme.primaryGradientEnd],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.35),
                                  offset: const Offset(0, 4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Spell Pop',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Word Adventure',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Pill badges: Coins counter (Tap to watch ad & get coins) & Theme button
                      Row(
                        children: [
                          // Interactive 3D Coin/Star Counter Pill with Ad / Unlock modal trigger
                          const CoinBalancePill()
                              .animate()
                              .scale(duration: 400.ms, curve: Curves.elasticOut),

                          const SizedBox(width: 8),

                          // How to Play / Info Button
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: IconButton(
                              tooltip: 'How to Play & Modes',
                              onPressed: () => _showHowToPlayDialog(context, theme, isDark),
                              icon: const Icon(
                                Icons.help_outline_rounded,
                                color: AppTheme.primaryColor,
                                size: 22,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Theme Toggle Button
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () => settingsNotifier.toggleTheme(),
                              icon: Icon(
                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                color: isDark ? AppTheme.sunnyYellow : AppTheme.primaryColor,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // 2. DAILY STREAK BANNER
                  if (gameState.streak > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xffff6b4a), Color(0xffff8e53)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xffff6b4a).withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_fire_department_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${gameState.streak} Days On Fire! 🔥',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Keep your daily streak alive today',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().slideY(begin: 0.1, duration: 350.ms),

                  // 3. MAIN HERO PLAY CARD (Vibrant 3D Island)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xff4338ca), const Color(0xff6366f1)]
                            : [const Color(0xff6366f1), const Color(0xff8b5cf6)],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative glowing bubble inside hero card
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(26.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Level Tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.flag_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      gameState.activeWord != null
                                          ? 'LEVEL ${gameState.currentLevel} • ${gameState.activeWord!.difficultyName.toUpperCase()}'
                                          : 'LEVEL ${gameState.currentLevel}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              Text(
                                gameState.activeWord != null
                                    ? gameState.activeWord!.category
                                    : 'Next Word Puzzle',
                                style: theme.textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                gameState.activeWord != null
                                    ? 'Mode: ${gameState.activeWord!.gameModeName} • Pop the tiles to spell!'
                                    : 'Solve spelling puzzles and unlock secret words!',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Big 3D Play Now Button
                              PopButton(
                                backgroundColor: AppTheme.sunnyYellow,
                                depth: 5,
                                shadowColor: const Color(0xffd97706),
                                borderRadius: BorderRadius.circular(22),
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                onTap: () => context.push('/game'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Color(0xff78350f),
                                      size: 30,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'PLAY NOW',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: const Color(0xff78350f),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 19,
                                        letterSpacing: 0.8,
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
                  ).animate().scale(
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                        begin: const Offset(0.95, 0.95),
                      ),

                  const SizedBox(height: 28),

                  // 4. GAME MODES SECTION TITLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Game Modes & Quests',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ALL ACTIVE',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 5. 2x2 MODES CARDS
                  Row(
                    children: [
                      // Categories
                      Expanded(
                        child: _buildModeCard(
                          context: context,
                          theme: theme,
                          isDark: isDark,
                          title: 'Categories',
                          subtitle: '30+ Themes',
                          icon: Icons.grid_view_rounded,
                          accentColor: AppTheme.tealAccent,
                          bgTint: isDark ? AppTheme.darkSurfaceColor : AppTheme.pastelMint,
                          onTap: () => context.push('/categories'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Time Attack
                      Expanded(
                        child: _buildModeCard(
                          context: context,
                          theme: theme,
                          isDark: isDark,
                          title: 'Time Attack',
                          subtitle: 'Beat the 60s clock',
                          icon: Icons.timer_rounded,
                          accentColor: AppTheme.coralPink,
                          bgTint: isDark ? AppTheme.darkSurfaceColor : AppTheme.pastelPeach,
                          onTap: () => context.push('/time-attack'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      // Daily Puzzle
                      Expanded(
                        child: _buildModeCard(
                          context: context,
                          theme: theme,
                          isDark: isDark,
                          title: 'Daily Puzzle',
                          subtitle: '+50 Stars daily',
                          icon: Icons.calendar_today_rounded,
                          accentColor: AppTheme.sunnyYellow,
                          bgTint: isDark ? AppTheme.darkSurfaceColor : AppTheme.pastelYellow,
                          onTap: () => context.push('/daily-puzzle'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Achievements
                      Expanded(
                        child: _buildModeCard(
                          context: context,
                          theme: theme,
                          isDark: isDark,
                          title: 'Achievements',
                          subtitle: 'Trophies & Badges',
                          icon: Icons.emoji_events_rounded,
                          accentColor: AppTheme.primaryGradientEnd,
                          bgTint: isDark ? AppTheme.darkSurfaceColor : AppTheme.pastelLavender,
                          onTap: () => context.push('/achievements'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 6. SETTINGS BUTTON (Modern Pill Bar)
                  Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/settings'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkSurfaceColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.1),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 18,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Settings & Sound',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color bgTint,
    required VoidCallback onTap,
  }) {
    return PopButton(
      backgroundColor: bgTint,
      depth: 3.5,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.4)
          : accentColor.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(18),
      border: Border.all(
        color: accentColor.withValues(alpha: 0.2),
        width: 1.5,
      ),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with glossy background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _showHowToPlayDialog(BuildContext context, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 25,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pill Handle
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'About Spell Pop',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.pop(modalCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Explore every game mode and how spelling puzzles work!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 18),

                // Mode Cards List
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // 1. Classic Adventure
                      _buildGuideCard(
                        theme: theme,
                        isDark: isDark,
                        icon: Icons.play_circle_fill_rounded,
                        color: AppTheme.primaryColor,
                        title: '1. Classic Adventure (Play Now)',
                        description:
                            'Progress through hundreds of curated spelling levels from Easy to Expert.\n• Earn stars on completion.\n• Unlock categories as you beat milestones.\n• Encounter 3 distinct puzzle types explained below!',
                      ),
                      const SizedBox(height: 14),

                      // 2. Unscramble Mode
                      _buildGuideCard(
                        theme: theme,
                        isDark: isDark,
                        icon: Icons.shuffle_rounded,
                        color: AppTheme.coralPink,
                        title: 'Puzzle Type: Unscramble',
                        description:
                            'Floating 3D letter bubbles appear in mixed order.\n• Tap bubbles in the correct sequence to spell the word.\n• Tap any filled slot if you made a mistake to return that letter back to the pool.',
                      ),
                      const SizedBox(height: 14),

                      // 3. Missing Letters Mode
                      _buildGuideCard(
                        theme: theme,
                        isDark: isDark,
                        icon: Icons.edit_note_rounded,
                        color: AppTheme.tealAccent,
                        title: 'Puzzle Type: Missing Letters',
                        description:
                            'Some letters in the word are already revealed.\n• Tap the active slot.\n• Use the custom on-screen keyboard (A-Z) to fill in the missing blanks.',
                      ),
                      const SizedBox(height: 14),

                      // 4. Choose Spelling Mode
                      _buildGuideCard(
                        theme: theme,
                        isDark: isDark,
                        icon: Icons.check_circle_outline_rounded,
                        color: AppTheme.mintGreen,
                        title: 'Puzzle Type: Choose Spelling',
                        description:
                            'Multiple similar spellings will be shown on cards.\n• Spot and tap the one true correct spelling.\n• Tests vocabulary and tricky silent letters!',
                      ),
                      const SizedBox(height: 14),

                      // 5. Time Attack
                      _buildGuideCard(
                        theme: theme,
                        isDark: isDark,
                        icon: Icons.timer_rounded,
                        color: const Color(0xfff59e0b),
                        title: '2. Time Attack Mode',
                        description:
                            'Race against a 60-second timer!\n• Correct Word: +1 Score & +2 Extra Seconds.\n• Mistake: -3 Seconds penalty.\n• Set new personal bests to earn +50 stars bonus!',
                      ),
                      const SizedBox(height: 14),

                      // 6. Daily Mystery Puzzle
                      _buildGuideCard(
                        theme: theme,
                        isDark: isDark,
                        icon: Icons.calendar_today_rounded,
                        color: const Color(0xff8b5cf6),
                        title: '3. Daily Challenge & Streaks',
                        description:
                            'A brand-new mystery word puzzle every calendar day.\n• Complete it to maintain your daily fire streak.\n• Win +50 stars daily, with an option to double your reward to +100!',
                      ),
                      const SizedBox(height: 14),

                      // 7. Categories
                      _buildGuideCard(
                        theme: theme,
                        isDark: isDark,
                        icon: Icons.grid_view_rounded,
                        color: const Color(0xffec4899),
                        title: '4. Themed Categories',
                        description:
                            'Practice specific topics like Animals, Space, Sports, Food, and Nature.\n• Unlock higher categories by completing levels in Classic Adventure.',
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),

                // Dismiss Button
                PopButton(
                  backgroundColor: AppTheme.primaryColor,
                  depth: 4,
                  shadowColor: const Color(0xff4338ca),
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onTap: () => Navigator.pop(modalCtx),
                  child: const Center(
                    child: Text(
                      'GOT IT, LET\'S PLAY!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuideCard({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    height: 1.45,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
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
