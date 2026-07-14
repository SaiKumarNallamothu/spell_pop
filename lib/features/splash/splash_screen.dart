import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

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
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xff1e293b), const Color(0xff0f172a)]
                    : [const Color(0xffeff6ff), const Color(0xffdbeafe)],
              ),
            ),
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder icon (Animated)
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff3b82f6), Color(0xff60a5fa)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff3b82f6).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .rotate(duration: 600.ms, curve: Curves.elasticOut),
              
              const SizedBox(height: 24),
              
              // Spelling "SpellPop" split letters animated sequence
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: 'SPELLPOP'.split('').asMap().entries.map((entry) {
                  int idx = entry.key;
                  String char = entry.value;
                  return Text(
                    char,
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: char == 'P' || char == 'O'
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.08),
                          offset: const Offset(2, 4),
                          blurRadius: 4,
                        )
                      ],
                    ),
                  )
                      .animate(delay: (100 * idx).ms)
                      .scale(
                        duration: 300.ms,
                        curve: Curves.elasticOut,
                        begin: const Offset(0, 0),
                      )
                      .shake(duration: 300.ms);
                }).toList(),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Fun Spelling Puzzles!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              )
                  .animate(delay: 1000.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),
            ],
          ),
          
          // Version info at bottom
          Positioned(
            bottom: 30,
            child: Text(
              'v1.0.0',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
              ),
            )
                .animate(delay: 1200.ms)
                .fadeIn(duration: 500.ms),
          )
        ],
      ),
    );
  }
}
