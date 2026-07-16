import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/providers/game_state.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/pop_button.dart';
import '../../app/theme/theme.dart';
import '../../core/providers/services_provider.dart';

class DailyPuzzleScreen extends ConsumerStatefulWidget {
  const DailyPuzzleScreen({super.key});

  @override
  ConsumerState<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends ConsumerState<DailyPuzzleScreen> {
  bool _isClaimed = false;
  bool _isDoubled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gameState = ref.watch(gameStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Challenge',
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // STREAK STATUS
              GlassCard(
                padding: const EdgeInsets.all(24.0),
                backgroundColor: isDark ? const Color(0xff1e293b) : Colors.white,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        color: theme.colorScheme.secondary,
                        size: 40,
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .scale(end: const Offset(1.15, 1.15), duration: 800.ms),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${gameState.streak} Day Streak!',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Solve today\'s word to expand your streak and win bonus stars!',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.1, duration: 300.ms),
              
              const SizedBox(height: 24),

              // WEEK CALENDAR
              Text(
                'Weekly Progress',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final dayName = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index];
                  // Mock that past days are checked, today is active
                  final bool isPassed = index < 3;
                  final bool isToday = index == 3;
                  
                  Color circleBg = theme.dividerColor.withOpacity(0.05);
                  Color borderCol = Colors.transparent;
                  Color textCol = theme.textTheme.bodyMedium?.color ?? Colors.grey;

                  if (isPassed) {
                    circleBg = theme.colorScheme.primary.withOpacity(0.15);
                    textCol = theme.colorScheme.primary;
                  } else if (isToday) {
                    circleBg = theme.colorScheme.secondary.withOpacity(0.15);
                    borderCol = theme.colorScheme.secondary;
                    textCol = theme.colorScheme.secondary;
                  }

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: circleBg,
                        borderRadius: BorderRadius.circular(16),
                        border: borderCol != Colors.transparent
                            ? Border.all(color: borderCol, width: 2)
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            dayName,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textCol,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            isPassed 
                                ? Icons.check_circle_rounded 
                                : (isToday ? Icons.play_circle_fill_rounded : Icons.lock_outline_rounded),
                            color: textCol,
                            size: 20,
                          ),
                        ],
                      ),
                    ).animate(delay: (index * 50).ms).scale(duration: 250.ms),
                  );
                }),
              ),
              
              const SizedBox(height: 28),

              // DAILY PUZZLE TASK CARD
              Text(
                'Today\'s Challenge',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              GlassCard(
                padding: const EdgeInsets.all(24),
                gradient: LinearGradient(
                  colors: isDark 
                      ? [const Color(0xff1e1b4b), const Color(0xff311042)]
                      : [const Color(0xffe0e7ff), const Color(0xfff3e8ff)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'SPECIAL PUZZLE',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xfff59e0b), size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '+50 Stars',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: const Color(0xfff59e0b),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Spelling Explorer',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Category: Environment • Difficulty: Expert',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    
                    _isClaimed 
                      ? Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.success.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: theme.colorScheme.success),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Today\'s Reward Claimed!',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!_isDoubled) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: PopButton(
                                      backgroundColor: theme.colorScheme.secondary,
                                      onTap: () {
                                        ref.read(adServiceProvider).showRewardedAd(() {
                                          ref.read(gameStateProvider.notifier).doubleDailyReward();
                                          setState(() {
                                            _isDoubled = true;
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Congratulations! Stars doubled (+50 more stars added).'),
                                              backgroundColor: theme.colorScheme.success,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          );
                                        }, () {
                                          // ad show fail fallback handled by service
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.video_library_rounded, color: Colors.white),
                                          const SizedBox(width: 8),
                                          const Flexible(
                                            child: Text(
                                              'Watch Video to Double! (+50⭐)',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: PopButton(
                                backgroundColor: theme.colorScheme.primary,
                                onTap: () {
                                  // Trigger daily complete
                                  ref.read(gameStateProvider.notifier).completeDailyPuzzle();
                                  setState(() {
                                    _isClaimed = true;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Congratulations! +50 Stars added to your balance.'),
                                      backgroundColor: theme.colorScheme.success,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Solve Puzzle'),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
              ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
            ],
          ),
        ),
      ),
    );
  }
}
