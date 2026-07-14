import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/pop_button.dart';

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
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
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
          // Semi-transparent background dimming
          Container(
            color: Colors.black.withOpacity(0.65),
          ),
          
          // Confetti emitter
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow
            ],
          ),

          // Central Celebratory Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff1e293b) : Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Accent Gradient
                  Container(
                    height: 12,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff3b82f6), Color(0xfff59e0b), Color(0xff22c55e)],
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      children: [
                        // Star Reward Ring
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xfff59e0b).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Color(0xfff59e0b),
                            size: 64,
                          ),
                        )
                            .animate()
                            .scale(duration: 500.ms, curve: Curves.elasticOut)
                            .rotate(duration: 500.ms, curve: Curves.elasticOut),
                        
                        const SizedBox(height: 20),
                        
                        Text(
                          'AMAZING!',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xff22c55e),
                          ),
                        )
                            .animate(delay: 200.ms)
                            .slideY(begin: 0.1, duration: 350.ms)
                            .fadeIn(duration: 250.ms),
                        
                        const SizedBox(height: 8),
                        
                        // Word solved details
                        Text(
                          'You correctly spelled:',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.correctWord.toUpperCase(),
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Reward block
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.06),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xfff59e0b), size: 22),
                              const SizedBox(width: 6),
                              Text(
                                '+${widget.starsEarned} Stars Earned',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // Nav Buttons
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: PopButton(
                                    backgroundColor: theme.colorScheme.primary,
                                    onTap: widget.onNextLevel,
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Next Level'),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: widget.onRetry,
                                    child: Text(
                                      'Retry Level',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontSize: 15,
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextButton(
                                    onPressed: widget.onHome,
                                    child: Text(
                                      'Home Screen',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontSize: 15,
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                        fontWeight: FontWeight.bold,
                                      ),
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
                .scale(duration: 400.ms, curve: Curves.easeOutBack, begin: const Offset(0.8, 0.8)),
          ),
        ],
      ),
    );
  }
}
