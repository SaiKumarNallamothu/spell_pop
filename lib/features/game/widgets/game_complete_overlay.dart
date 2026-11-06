import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/pop_button.dart';
import '../../../app/theme/theme.dart';

class GameCompleteOverlay extends StatefulWidget {
  final String correctWord;
  final int starsEarned;
  final VoidCallback onNextLevel;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  const GameCompleteOverlay({
    super.key,
    required this.correctWord,
    required this.starsEarned,
    required this.onNextLevel,
    required this.onRetry,
    required this.onHome,
  });

  @override
  State<GameCompleteOverlay> createState() => _GameCompleteOverlayState();
}

class _GameCompleteOverlayState extends State<GameCompleteOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gentle ambient dark backdrop
          Container(
            color: Colors.black.withValues(alpha: 0.7),
          ),

          // Confetti explosion
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 35,
            gravity: 0.2,
            colors: const [
              AppTheme.coralPink,
              AppTheme.sunnyYellow,
              AppTheme.mintGreen,
              AppTheme.primaryColor,
              AppTheme.tealAccent,
              Color(0xfff472b6),
            ],
          ),

          // Central 3D Celebration Modal Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xfff1f5f9),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Rainbow Ribbon Glow
                  Container(
                    height: 10,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.coralPink,
                          AppTheme.sunnyYellow,
                          AppTheme.mintGreen,
                          AppTheme.primaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                    child: Column(
                      children: [
                        // Bouncing Trophy / Star Badge
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xffffd000), Color(0xffff9900)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.sunnyYellow.withValues(alpha: 0.45),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 56,
                            ),
                          ),
                        )
                            .animate()
                            .scale(duration: 500.ms, curve: Curves.elasticOut)
                            .rotate(duration: 500.ms, curve: Curves.elasticOut),

                        const SizedBox(height: 18),

                        // Title Text
                        Text(
                          'SPELL POP!',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: AppTheme.coralPink,
                          ),
                        )
                            .animate(delay: 150.ms)
                            .slideY(begin: 0.1, duration: 300.ms)
                            .fadeIn(duration: 200.ms),

                        const SizedBox(height: 6),

                        Text(
                          'You correctly spelled:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Word Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.primaryColor.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            widget.correctWord.toUpperCase(),
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Reward Pill with 3D depth
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.sunnyYellow.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.sunnyYellow.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppTheme.sunnyYellow,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+${widget.starsEarned} STARS EARNED',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: const Color(0xffb45309),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Actions
                        Column(
                          children: [
                            // Next Level Pop Button
                            PopButton(
                              backgroundColor: AppTheme.mintGreen,
                              depth: 5,
                              shadowColor: const Color(0xff059669),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              onTap: widget.onNextLevel,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'NEXT LEVEL',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  onPressed: widget.onRetry,
                                  icon: const Icon(Icons.replay_rounded, size: 18),
                                  label: const Text('Retry'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.primaryColor,
                                    textStyle: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                TextButton.icon(
                                  onPressed: widget.onHome,
                                  icon: const Icon(Icons.home_rounded, size: 18),
                                  label: const Text('Main Menu'),
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                                    textStyle: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .scale(duration: 400.ms, curve: Curves.easeOutBack, begin: const Offset(0.85, 0.85)),
          ),
        ],
      ),
    );
  }
}
