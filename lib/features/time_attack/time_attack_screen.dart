import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/providers/game_state.dart';
import '../../models/word_model.dart';
import '../../shared/widgets/pop_button.dart';
import '../../app/theme/theme.dart';
import '../../core/providers/services_provider.dart';

class TimeAttackScreen extends ConsumerStatefulWidget {
  const TimeAttackScreen({super.key});

  @override
  ConsumerState<TimeAttackScreen> createState() => _TimeAttackScreenState();
}

class _TimeAttackScreenState extends ConsumerState<TimeAttackScreen> {
  int _activeSlotIndex = 0;
  List<String> _keyboardLetters = [];
  bool _hasContinued = false;

  @override
  void initState() {
    super.initState();
    // Start Time Attack mode on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameStateProvider.notifier).startTimeAttack();
      _initializeInputs();
    });
  }

  void _initializeInputs() {
    final gameState = ref.read(gameStateProvider);
    final word = gameState.activeWord;
    if (word == null) return;

    if (word.gameMode == GameMode.chooseSpelling) return;

    int firstEmpty = gameState.userAnswerLetters.indexOf('');
    setState(() {
      _activeSlotIndex = firstEmpty != -1 ? firstEmpty : 0;
      _keyboardLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    });
  }

  void _onLetterTap(String letter) {
    final gameState = ref.read(gameStateProvider);
    final word = gameState.activeWord;
    if (word == null) return;

    ref.read(gameStateProvider.notifier).fillLetter(_activeSlotIndex, letter);
    
    // Auto check if fully filled, otherwise move to next slot
    final updatedLetters = ref.read(gameStateProvider).userAnswerLetters;
    int nextEmpty = updatedLetters.indexOf('', _activeSlotIndex + 1);
    if (nextEmpty == -1) {
      nextEmpty = updatedLetters.indexOf(''); // wrap around
    }
    
    if (nextEmpty != -1) {
      setState(() {
        _activeSlotIndex = nextEmpty;
      });
    } else {
      // Auto check and transition
      ref.read(gameStateProvider.notifier).submitTimeAttackAnswer();
      _initializeInputs();
    }
  }

  void _onSlotClear(int slotIndex) {
    final gameState = ref.read(gameStateProvider);
    final word = gameState.activeWord;
    if (word == null) return;

    // Prefilled letters in Time Attack are allowed to be cleared just in case,
    // but typically let the user clear their typed letters.
    ref.read(gameStateProvider.notifier).clearLetter(slotIndex);
    setState(() {
      _activeSlotIndex = slotIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final gameState = ref.watch(gameStateProvider);
    final word = gameState.activeWord;

    if (word == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  // HEADER STATS (Score, Timer, High Score)
                  _buildHeader(theme, gameState),
                  
                  const Spacer(flex: 1),

                  // TOPIC INDICATOR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'CATEGORY: ${word.category.toUpperCase()}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // PUZZLE CONTAINER
                  _buildPuzzleArea(theme, gameState, word)
                      .animate(target: gameState.isWrongAnswerShake ? 1 : 0)
                      .shake(duration: 300.ms, curve: Curves.easeInOut),

                  const Spacer(flex: 2),

                  // INPUT CONTAINER
                  _buildInputPanel(theme, gameState, word),

                  const Spacer(flex: 2),

                  // QUIT BUTTON (DURING GAME)
                  TextButton.icon(
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).exitTimeAttack();
                      context.pop();
                    },
                    icon: const Icon(Icons.exit_to_app_rounded),
                    label: const Text('Exit Challenge'),
                    style: TextButton.styleFrom(foregroundColor: theme.disabledColor),
                  ),
                ],
              ),
            ),
          ),

          // GAME OVER OVERLAY
          if (gameState.isTimeAttackOver)
            _buildGameOverOverlay(theme, gameState, isDark),
        ],
      ),
    );
  }

  // --- Header Area (Timer & Score) ---
  Widget _buildHeader(ThemeData theme, GameSessionState gameState) {
    final bool isCritical = gameState.timeAttackSecondsRemaining <= 10;
    final progress = gameState.timeAttackSecondsRemaining / 60.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Score Badge
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SCORE',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              '${gameState.timeAttackScore}',
              style: theme.textTheme.displayMedium?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),

        // Visual Countdown Timer
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 65,
              height: 65,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: theme.dividerColor.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCritical ? theme.colorScheme.error : theme.colorScheme.success,
                ),
              ),
            ),
            Text(
              '${gameState.timeAttackSecondsRemaining}s',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isCritical ? theme.colorScheme.error : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),

        // High Score Badge
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'HIGH SCORE',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              '${gameState.timeAttackHighScore}',
              style: theme.textTheme.displayMedium?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Puzzle Letters ---
  Widget _buildPuzzleArea(ThemeData theme, GameSessionState gameState, WordModel word) {
    if (word.gameMode == GameMode.chooseSpelling) {
      return Text(
        'Which spelling is correct?',
        style: theme.textTheme.displayMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final int wordLength = word.word.length;
    final double spacing = wordLength > 8 ? 4.0 : 8.0;
    final double paddingHorizontal = 40.0;
    final double availableWidth = screenWidth - paddingHorizontal - ((wordLength - 1) * spacing);
    final double calculatedSize = (availableWidth / wordLength).clamp(32.0, 48.0);

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: List.generate(wordLength, (index) {
        final letter = gameState.userAnswerLetters[index];
        final bool isActive = index == _activeSlotIndex;

        return GestureDetector(
          onTap: () => _onSlotClear(index),
          child: Container(
            width: calculatedSize,
            height: calculatedSize * 1.12,
            decoration: BoxDecoration(
              color: isActive ? theme.colorScheme.primary.withOpacity(0.05) : theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive ? theme.colorScheme.primary : theme.dividerColor.withOpacity(0.12),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: theme.textTheme.displayMedium?.copyWith(
                fontSize: calculatedSize * 0.45,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  // --- Input Panel ---
  Widget _buildInputPanel(ThemeData theme, GameSessionState gameState, WordModel word) {
    if (word.gameMode == GameMode.chooseSpelling) {
      final options = word.options ?? [word.word, '${word.word}e', 'Aple'];
      return Column(
        children: options.map((opt) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 70),
            child: PopButton(
              backgroundColor: theme.cardColor,
              border: Border.all(color: theme.dividerColor.withOpacity(0.1), width: 1.5),
              boxShadow: const [],
              onTap: () {
                ref.read(gameStateProvider.notifier).chooseOption(opt);
                ref.read(gameStateProvider.notifier).submitTimeAttackAnswer();
              },
              child: Text(
                opt,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    // Default fast keyboard
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      alignment: WrapAlignment.center,
      children: _keyboardLetters.map((letter) {
        return SizedBox(
          width: 32,
          height: 44,
          child: PopButton(
            alignment: Alignment.center,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: theme.cardColor,
            padding: EdgeInsets.zero,
            border: Border.all(color: theme.dividerColor.withOpacity(0.08), width: 1),
            boxShadow: const [],
            onTap: () => _onLetterTap(letter),
            child: Text(
              letter,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- Game Over Overlay ---
  Widget _buildGameOverOverlay(ThemeData theme, GameSessionState gameState, bool isDark) {
    final bool isNewHigh = gameState.timeAttackScore >= gameState.timeAttackHighScore && gameState.timeAttackScore > 0;
    
    return Container(
      color: Colors.black.withOpacity(0.7),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff1e293b) : Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timer_off_rounded,
                  color: theme.colorScheme.error,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'TIME\'S UP!',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'High-speed spelling session completed.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),

              if (isNewHigh)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: Color(0xfff59e0b), size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'NEW HIGH SCORE!',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('Final Score', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${gameState.timeAttackScore}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Container(width: 1.5, height: 40, color: theme.dividerColor.withOpacity(0.15)),
                  Column(
                    children: [
                      Text('High Score', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${gameState.timeAttackHighScore}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 28),

              if (!_hasContinued) ...[
                Row(
                  children: [
                    Expanded(
                      child: PopButton(
                        backgroundColor: theme.colorScheme.secondary,
                        onTap: () {
                          ref.read(adServiceProvider).showRewardedAd(() {
                            ref.read(gameStateProvider.notifier).continueTimeAttack();
                            setState(() {
                              _hasContinued = true;
                            });
                          }, () {
                            // ad fail handled by service
                          });
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_library_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Watch Ad to Continue (+30s)'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: PopButton(
                      backgroundColor: theme.colorScheme.primary,
                      onTap: () {
                        ref.read(gameStateProvider.notifier).startTimeAttack();
                        _initializeInputs();
                        setState(() {
                          _hasContinued = false;
                        });
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.replay_rounded),
                          SizedBox(width: 8),
                          Text('Play Again'),
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
                      onPressed: () {
                        ref.read(gameStateProvider.notifier).exitTimeAttack();
                        context.go('/home');
                      },
                      child: Text(
                        'Exit to Home',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                          color: theme.disabledColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
