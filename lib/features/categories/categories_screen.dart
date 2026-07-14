import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/providers/game_state.dart';
import '../../shared/widgets/pop_button.dart';

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
    final gameState = ref.watch(gameStateProvider);

    // Dynamic mock statistics for completion rate based on completed levels
    final totalCompleted = gameState.completedLevels.length;
    final animalsPercent = totalCompleted > 0 ? (totalCompleted / 24).clamp(0.0, 1.0) : 0.0;
    final fruitsPercent = totalCompleted > 3 ? ((totalCompleted - 3) / 12).clamp(0.0, 1.0) : 0.0;
    final schoolPercent = totalCompleted > 6 ? ((totalCompleted - 6) / 10).clamp(0.0, 1.0) : 0.0;
    final transportPercent = totalCompleted > 9 ? ((totalCompleted - 9) / 8).clamp(0.0, 1.0) : 0.0;

    final List<CategoryItem> categories = [
      CategoryItem(
        name: 'Animals',
        icon: Icons.pets_rounded,
        themeColor: const Color(0xfff59e0b),
        completionRate: animalsPercent,
      ),
      CategoryItem(
        name: 'Fruits',
        icon: Icons.apple_rounded,
        themeColor: const Color(0xffef4444),
        completionRate: fruitsPercent,
      ),
      CategoryItem(
        name: 'School',
        icon: Icons.school_rounded,
        themeColor: const Color(0xff3b82f6),
        completionRate: schoolPercent,
      ),
      CategoryItem(
        name: 'Kitchen',
        icon: Icons.kitchen_rounded,
        themeColor: Colors.teal,
        completionRate: 0.0,
        isLocked: totalCompleted < 3,
      ),
      CategoryItem(
        name: 'Transport',
        icon: Icons.directions_bus_rounded,
        themeColor: Colors.indigo,
        completionRate: transportPercent,
        isLocked: totalCompleted < 5,
      ),
      CategoryItem(
        name: 'Space',
        icon: Icons.rocket_launch_rounded,
        themeColor: Colors.purple,
        completionRate: 0.0,
        isLocked: totalCompleted < 8,
      ),
      CategoryItem(
        name: 'Sports',
        icon: Icons.sports_soccer_rounded,
        themeColor: const Color(0xff22c55e),
        completionRate: 0.0,
        isLocked: totalCompleted < 10,
      ),
      CategoryItem(
        name: 'Computer',
        icon: Icons.computer_rounded,
        themeColor: Colors.pink,
        completionRate: 0.0,
        isLocked: totalCompleted < 12,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Spell Categories',
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine column count adaptively based on width
            int crossAxisCount = 2;
            if (constraints.maxWidth > 600) {
              crossAxisCount = 3;
            }
            if (constraints.maxWidth > 900) {
              crossAxisCount = 4;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  
                  // Description & stats header
                  Text(
                    'Complete categories to unlock advanced words and earn achievements!',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  
                  // Grid containing Category Cards
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
                        return _buildCategoryCard(context, item, theme)
                            .animate(delay: (index * 50).ms)
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

  Widget _buildCategoryCard(BuildContext context, CategoryItem item, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return PopButton(
      backgroundColor: isDark ? const Color(0xff1e293b) : Colors.white,
      padding: EdgeInsets.zero,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
      border: Border.all(
        color: theme.dividerColor.withOpacity(0.08),
        width: 1.5,
      ),
      onTap: item.isLocked
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Finish more levels to unlock ${item.name}!'),
                  backgroundColor: theme.colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          : () {
              // Start a spelling game directly focused on this category!
              // In this prototype, we'll route to game and set current category
              context.push('/game');
            },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon & Lock layout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.themeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.themeColor,
                    size: 28,
                  ),
                ),
                if (item.isLocked)
                  Icon(
                    Icons.lock_rounded,
                    color: theme.disabledColor,
                    size: 20,
                  )
                else
                  Text(
                    '${(item.completionRate * 100).toInt()}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: item.themeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            
            const Spacer(),
            
            // Name
            Text(
              item.name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: item.isLocked ? theme.disabledColor : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Progress Bar / Lock details
            if (item.isLocked)
              Text(
                'LOCKED',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.disabledColor,
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.completionRate,
                  backgroundColor: item.themeColor.withOpacity(0.1),
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
