import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/providers/game_state.dart';
import '../../app/theme/theme.dart';

class AchievementItem {
  final String title;
  final String description;
  final IconData icon;
  final Color baseColor;
  final int progress;
  final int maxProgress;

  AchievementItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.baseColor,
    required this.progress,
    required this.maxProgress,
  });

  bool get isUnlocked => progress >= maxProgress;
}

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final gameState = ref.watch(gameStateProvider);
    final levelsCompleted = gameState.completedLevels.length;
    final userStars = gameState.stars;
    final currentStreak = gameState.streak;

    final List<AchievementItem> achievements = [
      AchievementItem(
        title: 'First Win',
        description: 'Solve your first spelling word correctly.',
        icon: Icons.workspace_premium_rounded,
        baseColor: AppTheme.sunnyYellow,
        progress: levelsCompleted >= 1 ? 1 : 0,
        maxProgress: 1,
      ),
      AchievementItem(
        title: 'Spelling Starter',
        description: 'Complete 10 spelling words.',
        icon: Icons.military_tech_rounded,
        baseColor: AppTheme.tealAccent,
        progress: levelsCompleted.clamp(0, 10),
        maxProgress: 10,
      ),
      AchievementItem(
        title: 'Word Master',
        description: 'Solve 100 spelling words.',
        icon: Icons.emoji_events_rounded,
        baseColor: AppTheme.primaryGradientEnd,
        progress: levelsCompleted.clamp(0, 100),
        maxProgress: 100,
      ),
      AchievementItem(
        title: 'Star Collector',
        description: 'Accumulate 500 stars in total.',
        icon: Icons.star_rounded,
        baseColor: AppTheme.sunnyYellow,
        progress: userStars.clamp(0, 500),
        maxProgress: 500,
      ),
      AchievementItem(
        title: '7-Day Streak',
        description: 'Log in and solve a puzzle 7 days in a row.',
        icon: Icons.local_fire_department_rounded,
        baseColor: AppTheme.coralPink,
        progress: currentStreak.clamp(0, 7),
        maxProgress: 7,
      ),
      AchievementItem(
        title: 'Perfect Score',
        description: 'Solve a word without hints.',
        icon: Icons.auto_awesome_rounded,
        baseColor: AppTheme.mintGreen,
        progress: levelsCompleted >= 2 ? 1 : 0,
        maxProgress: 1,
      ),
      AchievementItem(
        title: 'Fast Solver',
        description: 'Complete a level in less than 5 seconds.',
        icon: Icons.bolt_rounded,
        baseColor: const Color(0xff38bdf8),
        progress: levelsCompleted >= 3 ? 1 : 0,
        maxProgress: 1,
      ),
      AchievementItem(
        title: 'Category Champion',
        description: 'Unlock and fully master all base word categories.',
        icon: Icons.military_tech_rounded,
        baseColor: const Color(0xffec4899),
        progress: levelsCompleted >= 15 ? 1 : 0,
        maxProgress: 1,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Achievements',
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
        child: Column(
          children: [
            // Stats summary card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol(theme, '$levelsCompleted', 'Solved Words', AppTheme.primaryColor),
                    Container(
                      height: 40,
                      width: 1.2,
                      color: theme.dividerColor.withValues(alpha: 0.12),
                    ),
                    _buildStatCol(
                      theme,
                      '${achievements.where((e) => e.isUnlocked).length}/${achievements.length}',
                      'Badges',
                      AppTheme.coralPink,
                    ),
                    Container(
                      height: 40,
                      width: 1.2,
                      color: theme.dividerColor.withValues(alpha: 0.12),
                    ),
                    _buildStatCol(theme, '$userStars', 'Total Stars', AppTheme.sunnyYellow),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Achievements list view
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final item = achievements[index];
                  return _buildAchievementCard(context, item, theme, isDark)
                      .animate(delay: (index * 40).ms)
                      .slideX(begin: 0.05, duration: 250.ms)
                      .fadeIn(duration: 200.ms);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCol(ThemeData theme, String value, String label, Color accentColor) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
      BuildContext context, AchievementItem item, ThemeData theme, bool isDark) {
    final progressVal = item.progress / item.maxProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: item.isUnlocked
              ? item.baseColor.withValues(alpha: 0.3)
              : theme.dividerColor.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: item.isUnlocked
                ? item.baseColor.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            // Shining badge element
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: item.isUnlocked
                    ? LinearGradient(
                        colors: [item.baseColor, item.baseColor.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade400, Colors.grey.shade500],
                      ),
                shape: BoxShape.circle,
                boxShadow: item.isUnlocked
                    ? [
                        BoxShadow(
                          color: item.baseColor.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Icon(
                item.icon,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // Text details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: item.isUnlocked
                              ? theme.colorScheme.onSurface
                              : theme.disabledColor,
                        ),
                      ),
                      if (item.isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.baseColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'UNLOCKED',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: item.baseColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progressVal,
                            backgroundColor: item.isUnlocked
                                ? item.baseColor.withValues(alpha: 0.12)
                                : theme.dividerColor.withValues(alpha: 0.08),
                            color: item.isUnlocked ? item.baseColor : theme.disabledColor,
                            minHeight: 7,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${item.progress}/${item.maxProgress}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
