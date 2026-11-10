import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/game/game_screen.dart';
import '../../features/time_attack/time_attack_screen.dart';
import '../../features/achievements/achievements_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/daily_puzzle/daily_puzzle_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
    GoRoute(
      path: '/categories',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const CategoriesScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.08);
          const end = Offset.zero;
          final curve = CurveTween(curve: Curves.easeOutCubic);
          final tween = Tween(begin: begin, end: end).chain(curve);
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    ),
    GoRoute(
      path: '/game',
      pageBuilder: (context, state) {
        final category = state.extra as String? ?? state.uri.queryParameters['category'];
        return CustomTransitionPage(
          key: state.pageKey,
          child: GameScreen(category: category),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final curve = CurveTween(curve: Curves.easeOutCubic);
          final tween = Tween(begin: begin, end: end).chain(curve);
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
    },
  ),
    GoRoute(
      path: '/time-attack',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const TimeAttackScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final curve = CurveTween(curve: Curves.easeOutBack);
          final tween = Tween(begin: begin, end: end).chain(curve);
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ),
    GoRoute(
      path: '/achievements',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AchievementsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -0.05);
          const end = Offset.zero;
          final curve = CurveTween(curve: Curves.easeOutCubic);
          final tween = Tween(begin: begin, end: end).chain(curve);
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    ),
    GoRoute(
      path: '/daily-puzzle',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const DailyPuzzleScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: CurveTween(curve: Curves.easeOutCubic).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
  ],
);
