import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/providers/game_state.dart';
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Daily Challenge',
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. STREAK HERO CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffff6b4a), Color(0xffff8e53)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffff6b4a).withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.white,
                        size: 42,
                      )
                          .animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .scale(end: const Offset(1.15, 1.15), duration: 800.ms),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${gameState.streak} DAY STREAK!',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Keep the flame burning to unlock rare trophies and bonus stars!',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.1, duration: 300.ms),

              const SizedBox(height: 24),

              // 2. WEEKLY CALENDAR PILLS
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Weekly Quest Trail',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final dayName = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index];
                  final bool isPassed = index < 3;
                  final bool isToday = index == 3;

                  Color boxBg = isDark ? AppTheme.darkSurfaceColor : Colors.white;
                  Color borderCol = isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xffe2e8f0);
                  Color textCol = theme.textTheme.bodyMedium?.color ?? Colors.grey;

                  if (isPassed) {
                    boxBg = AppTheme.mintGreen.withValues(alpha: 0.15);
                    borderCol = AppTheme.mintGreen;
                    textCol = AppTheme.mintGreen;
                  } else if (isToday) {
                    boxBg = AppTheme.sunnyYellow.withValues(alpha: 0.2);
                    borderCol = AppTheme.sunnyYellow;
                    textCol = const Color(0xffb45309);
                  }

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: boxBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderCol, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            dayName,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: textCol,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            isPassed
                                ? Icons.check_circle_rounded
                                : (isToday
                                    ? Icons.star_rounded
                                    : Icons.lock_outline_rounded),
                            color: textCol,
                            size: 20,
                          ),
                        ],
                      ),
                    ).animate(delay: (index * 40).ms).scale(duration: 250.ms),
                  );
                }),
              ),

              const SizedBox(height: 28),

              // 3. TODAY'S PUZZLE CARD
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Today\'s Mystery Word',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xff1e1b4b), const Color(0xff311042)]
                        : [const Color(0xffe0e7ff), const Color(0xfffae8ff)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'SPECIAL PUZZLE',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.sunnyYellow.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppTheme.sunnyYellow, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '+50 Stars',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: const Color(0xffb45309),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'Spelling Explorer',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Category: Environment • Difficulty: Master',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _isClaimed
                        ? Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: AppTheme.mintGreen.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.mintGreen.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        color: AppTheme.mintGreen, size: 24),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Today\'s Reward Claimed!',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: AppTheme.mintGreen,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!_isDoubled) ...[
                                const SizedBox(height: 14),
                                PopButton(
                                  backgroundColor: AppTheme.sunnyYellow,
                                  depth: 4.5,
                                  shadowColor: const Color(0xffd97706),
                                  onTap: () {
                                    ref.read(adServiceProvider).showRewardedAd(() {
                                      ref.read(gameStateProvider.notifier).doubleDailyReward();
                                      setState(() => _isDoubled = true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                              'Stars Doubled! +50 More Stars Awarded! 🎉'),
                                          backgroundColor: AppTheme.mintGreen,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16)),
                                        ),
                                      );
                                    }, () {});
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.video_library_rounded,
                                          color: Color(0xff78350f), size: 22),
                                      SizedBox(width: 8),
                                      Text(
                                        'DOUBLE REWARD (+50⭐)',
                                        style: TextStyle(
                                          color: Color(0xff78350f),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          )
                        : PopButton(
                            backgroundColor: AppTheme.primaryColor,
                            depth: 4.5,
                            shadowColor: const Color(0xff4338ca),
                            onTap: () {
                              ref.read(gameStateProvider.notifier).completeDailyPuzzle();
                              setState(() => _isClaimed = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Congratulations! +50 Stars added to your balance! ⭐'),
                                  backgroundColor: AppTheme.mintGreen,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'SOLVE PUZZLE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 17,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                              ],
                            ),
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
