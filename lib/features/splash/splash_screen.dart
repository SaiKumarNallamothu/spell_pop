import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final letters = [
      {'char': 'S', 'color': AppTheme.coralPink},
      {'char': 'P', 'color': AppTheme.sunnyYellow},
      {'char': 'E', 'color': AppTheme.mintGreen},
      {'char': 'L', 'color': AppTheme.tealAccent},
      {'char': 'L', 'color': AppTheme.primaryColor},
      {'char': 'P', 'color': AppTheme.coralPink},
      {'char': 'O', 'color': AppTheme.sunnyYellow},
      {'char': 'P', 'color': AppTheme.primaryGradientEnd},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Pastel ambient background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xff1e1b4b), const Color(0xff0f111a)]
                    : [const Color(0xfff5f7fb), const Color(0xffe0e7ff)],
              ),
            ),
          ),

          // Floating background bubbles
          Positioned(
            top: 100,
            left: 40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.coralPink.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: 40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.sunnyYellow.withValues(alpha: 0.1),
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3D Game Logo Mascot Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryGradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 54,
                  ),
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .rotate(duration: 600.ms, curve: Curves.elasticOut),

              const SizedBox(height: 28),

              // Bouncing colorful letters
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: letters.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Map<String, dynamic> item = entry.value;
                  final String char = item['char'] as String;
                  final Color col = item['color'] as Color;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: Text(
                      char,
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: col,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: col.withValues(alpha: 0.35),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate(delay: (90 * idx).ms)
                      .scale(
                        duration: 350.ms,
                        curve: Curves.elasticOut,
                        begin: const Offset(0, 0),
                      )
                      .shake(duration: 250.ms);
                }).toList(),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Casual Word Puzzles',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    fontSize: 13,
                  ),
                ),
              )
                  .animate(delay: 800.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
            ],
          ),

          // Bottom version tag
          Positioned(
            bottom: 30,
            child: Text(
              'v1.0.0 • 2025 Edition',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
              ),
            ).animate(delay: 1000.ms).fadeIn(duration: 400.ms),
          ),
        ],
      ),
    );
  }
}
