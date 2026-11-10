import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/providers/game_state.dart';
import '../../shared/widgets/pop_button.dart';
import '../../app/theme/theme.dart';

class CategoryItem {
  final String name;
  final IconData icon;
  final Color themeColor;
  final bool isLocked;
  final double completionRate;

  CategoryItem({
    required this.name,
    required this.icon,
    required this.themeColor,
    this.isLocked = false,
    this.completionRate = 0.0,
  });
}

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gameState = ref.watch(gameStateProvider);

    final totalCompleted = gameState.completedLevels.length;
    final animalsPercent = totalCompleted > 0 ? (totalCompleted / 24).clamp(0.0, 1.0) : 0.0;
    final fruitsPercent = totalCompleted > 3 ? ((totalCompleted - 3) / 12).clamp(0.0, 1.0) : 0.0;
    final schoolPercent = totalCompleted > 6 ? ((totalCompleted - 6) / 10).clamp(0.0, 1.0) : 0.0;
    final transportPercent = totalCompleted > 9 ? ((totalCompleted - 9) / 8).clamp(0.0, 1.0) : 0.0;

    final List<CategoryItem> categories = [
      CategoryItem(
        name: 'Animals',
        icon: Icons.pets_rounded,
        themeColor: AppTheme.coralPink,
        completionRate: animalsPercent,
      ),
      CategoryItem(
        name: 'Fruits',
        icon: Icons.apple_rounded,
        themeColor: const Color(0xfff43f5e),
        completionRate: fruitsPercent,
      ),
      CategoryItem(
        name: 'School',
        icon: Icons.school_rounded,
        themeColor: AppTheme.primaryColor,
        completionRate: schoolPercent,
      ),
      CategoryItem(
        name: 'Kitchen',
        icon: Icons.kitchen_rounded,
        themeColor: AppTheme.tealAccent,
        completionRate: 0.0,
        isLocked: totalCompleted < 3,
      ),
      CategoryItem(
        name: 'Transport',
        icon: Icons.directions_bus_rounded,
        themeColor: const Color(0xff3b82f6),
        completionRate: transportPercent,
        isLocked: totalCompleted < 5,
      ),
      CategoryItem(
        name: 'Space',
        icon: Icons.rocket_launch_rounded,
        themeColor: AppTheme.primaryGradientEnd,
        completionRate: 0.0,
        isLocked: totalCompleted < 8,
      ),
      CategoryItem(
        name: 'Sports',
        icon: Icons.sports_soccer_rounded,
        themeColor: AppTheme.mintGreen,
        completionRate: 0.0,
        isLocked: totalCompleted < 10,
      ),
      CategoryItem(
        name: 'Computer',
        icon: Icons.computer_rounded,
        themeColor: const Color(0xffec4899),
        completionRate: 0.0,
        isLocked: totalCompleted < 12,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Spell Categories',
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 2;
            if (constraints.maxWidth > 600) crossAxisCount = 3;
            if (constraints.maxWidth > 900) crossAxisCount = 4;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Header summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppTheme.tealAccent.withValues(alpha: 0.2),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.tealAccent.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.tealAccent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppTheme.tealAccent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Complete categories to unlock advanced words and earn rare badges!',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Categories Grid
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final item = categories[index];
                        return _buildCategoryCard(context, item, theme, isDark)
                            .animate(delay: (index * 45).ms)
                            .scale(duration: 300.ms, curve: Curves.easeOutBack)
                            .fadeIn(duration: 200.ms);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, CategoryItem item, ThemeData theme, bool isDark) {
    return PopButton(
      backgroundColor: isDark ? AppTheme.darkSurfaceColor : Colors.white,
      depth: item.isLocked ? 1.0 : 4.0,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.4)
          : item.themeColor.withValues(alpha: 0.25),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(
        color: item.isLocked
            ? theme.dividerColor.withValues(alpha: 0.08)
            : item.themeColor.withValues(alpha: 0.22),
        width: 1.5,
      ),
      onTap: item.isLocked
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Solve more levels to unlock ${item.name}! 🔒'),
                  backgroundColor: AppTheme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            }
          : () {
              context.push('/game', extra: item.name);
            },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon bubble
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.isLocked
                        ? theme.disabledColor.withValues(alpha: 0.1)
                        : item.themeColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.isLocked ? theme.disabledColor : item.themeColor,
                    size: 26,
                  ),
                ),
                if (item.isLocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.disabledColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      color: theme.disabledColor,
                      size: 16,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.themeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(item.completionRate * 100).toInt()}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: item.themeColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),

            const Spacer(),

            Text(
              item.name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: item.isLocked ? theme.disabledColor : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            // Progress bar
            if (item.isLocked)
              Text(
                'LOCKED',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: theme.disabledColor,
                  letterSpacing: 0.5,
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: item.completionRate,
                  backgroundColor: item.themeColor.withValues(alpha: 0.12),
                  color: item.themeColor,
                  minHeight: 6,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
