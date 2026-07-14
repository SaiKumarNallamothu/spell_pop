import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'providers/game_state.dart';
import '../../models/word_model.dart';
import 'widgets/game_complete_overlay.dart';
import '../../shared/widgets/pop_button.dart';
import '../../app/theme/theme.dart';
import '../../core/providers/services_provider.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int _activeSlotIndex = 0;
  List<String> _unscramblePool = [];
  List<String> _unscrambleSelectionOrder = [];
  List<String> _keyboardLetters = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeKeyboardAndPools();
    });
  }

  void _initializeKeyboardAndPools() {
    final gameState = ref.read(gameStateProvider);
    final word = gameState.activeWord;
    if (word == null) return;

    if (word.gameMode == GameMode.unscramble) {
      // Create a scrambled list of letters from the word
      final letters = word.word.split('');
      final rand = Random();
      // Keep scrambling until it is different from the original word
      int attempt = 0;
      do {
        letters.shuffle(rand);
        attempt++;
      } while (letters.join() == word.word && attempt < 10);
      
      setState(() {
        _unscramblePool = List<String>.from(letters);
        _unscrambleSelectionOrder = [];
        _activeSlotIndex = 0;
      });
    } else if (word.gameMode == GameMode.missingLetters) {
      // Find what slots are empty (need spelling)
      int firstEmpty = gameState.userAnswerLetters.indexOf('');
      setState(() {
        _activeSlotIndex = firstEmpty != -1 ? firstEmpty : 0;
        // Keyboard letters can be standard letters or a filtered list
        _keyboardLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
      });
    }
  }

  void _onLetterTap(String letter) {
    final gameState = ref.read(gameStateProvider);
    final word = gameState.activeWord;
    if (word == null) return;

    if (word.gameMode == GameMode.missingLetters) {
      ref.read(gameStateProvider.notifier).fillLetter(_activeSlotIndex, letter);
      
      // Auto move to the next empty slot
      final updatedLetters = ref.read(gameStateProvider).userAnswerLetters;
      int nextEmpty = updatedLetters.indexOf('', _activeSlotIndex + 1);
      if (nextEmpty == -1) {
        nextEmpty = updatedLetters.indexOf(''); // wrap around to beginning
      }
      
      if (nextEmpty != -1) {
        setState(() {
          _activeSlotIndex = nextEmpty;
        });
      }
    }
  }

  void _onUnscrambleTileTap(int poolIndex, String letter) {
    final gameState = ref.read(gameStateProvider);
    if (gameState.isLevelComplete) return;

    final firstEmptyIdx = gameState.userAnswerLetters.indexOf('');
    if (firstEmptyIdx != -1) {
      // Fill the slot
      ref.read(gameStateProvider.notifier).fillLetter(firstEmptyIdx, letter);
      
      setState(() {
        // Track the poolIndex that filled this slot
        _unscrambleSelectionOrder.add(poolIndex.toString());
      });
    }
  }

  void _onSlotClear(int slotIndex) {
    final gameState = ref.read(gameStateProvider);
    final word = gameState.activeWord;
    if (word == null || gameState.isLevelComplete) return;

    if (word.gameMode == GameMode.missingLetters) {
      // If it is prefilled, we don't clear it (keep it easy for kids)
      if (word.word[slotIndex] != gameState.userAnswerLetters[slotIndex]) {
        ref.read(gameStateProvider.notifier).clearLetter(slotIndex);
        setState(() {
          _activeSlotIndex = slotIndex;
        });
      }
    } else if (word.gameMode == GameMode.unscramble) {
      // For unscramble, we clear slots from right to left or specific index
      // If we clear, we must remove it from selection order and put it back in pool
      final letter = gameState.userAnswerLetters[slotIndex];
      if (letter.isNotEmpty) {
        ref.read(gameStateProvider.notifier).clearLetter(slotIndex);
        // Find which pool item filled this slot
        // To keep it simple, just clear all slots and restart or pop the last one
        if (_unscrambleSelectionOrder.isNotEmpty) {
          _unscrambleSelectionOrder.removeLast();
        }
      }
    }
  }

  void _resetUnscramble() {
    final gameState = ref.read(gameStateProvider);
    if (gameState.activeWord == null) return;
    ref.read(gameStateProvider.notifier).setupLevel(gameState.currentLevel);
    _initializeKeyboardAndPools();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Watch active game states
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
                  // HEADER ACTION BAR
                  _buildHeader(theme, gameState),
                  
                  const Spacer(flex: 1),

                  // PUZZLE WORD TITLE / CATEGORY
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'CATEGORY: ${word.category.toUpperCase()}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // DIFFICULTY LABEL
                  Text(
                    'Difficulty: ${word.difficultyName}',
                    style: theme.textTheme.bodyMedium,
                  ),

                  const Spacer(flex: 2),

                  // PUZZLE BLOCKS AREA
                  _buildPuzzleArea(theme, gameState, word)
                      .animate(target: gameState.isWrongAnswerShake ? 1 : 0)
                      .shake(duration: 300.ms, curve: Curves.easeInOut),

                  const Spacer(flex: 2),

                  // KEYBOARD / USER CHOICES AREA
                  _buildInputPanel(theme, gameState, word),

                  const Spacer(flex: 1),
                  
                  // HINT TOOLBAR
                  _buildHintBar(theme, gameState),
                  
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // CONFETTI CELEBRATION OVERLAY
          if (gameState.isLevelComplete)
            GameCompleteOverlay(
              correctWord: word.word,
              starsEarned: 10,
              onNextLevel: () {
                ref.read(gameStateProvider.notifier).nextLevel();
                _initializeKeyboardAndPools();
              },
              onRetry: () {
                ref.read(gameStateProvider.notifier).retryLevel();
                _initializeKeyboardAndPools();
              },
              onHome: () {
                context.go('/home');
              },
            ),
        ],
      ),
    );
  }

  // --- Header Area ---
  Widget _buildHeader(ThemeData theme, GameSessionState gameState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.pause_circle_filled_rounded, size: 28),
          color: theme.colorScheme.primary,
          onPressed: () => _showPauseDialog(theme),
        ),
        Text(
          'LEVEL ${gameState.currentLevel}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xfff59e0b), size: 18),
              const SizedBox(width: 4),
              Text(
                '${gameState.stars}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Puzzle Area (Letters display) ---
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
    // Calculate tile size responsive to screen width to keep them in a single row
    final double spacing = wordLength > 8 ? 4.0 : 8.0;
    final double paddingHorizontal = 40.0; // 20.0 padding on each side of the screen
    final double availableWidth = screenWidth - paddingHorizontal - ((wordLength - 1) * spacing);
    final double calculatedSize = (availableWidth / wordLength).clamp(32.0, 48.0);

    // List of slot boxes
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: List.generate(wordLength, (index) {
        final letter = gameState.userAnswerLetters[index];
        final bool isPrefilled = word.gameMode == GameMode.missingLetters && 
            word.word[index] == letter && 
            gameState.userAnswerLetters[index].isNotEmpty;
        final bool isActive = word.gameMode == GameMode.missingLetters && index == _activeSlotIndex;

        Color borderCol = theme.dividerColor.withOpacity(0.12);
        Color bgCol = theme.cardColor;

        if (isActive) {
          borderCol = theme.colorScheme.primary;
          bgCol = theme.colorScheme.primary.withOpacity(0.05);
        } else if (isPrefilled) {
          bgCol = theme.dividerColor.withOpacity(0.05);
        }

        return GestureDetector(
          onTap: () => _onSlotClear(index),
          child: Container(
            width: calculatedSize,
            height: calculatedSize * 1.12,
            decoration: BoxDecoration(
              color: bgCol,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderCol, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: theme.textTheme.displayMedium?.copyWith(
                fontSize: calculatedSize * 0.45,
                fontWeight: FontWeight.bold,
                color: isPrefilled 
                    ? theme.textTheme.bodyMedium?.color?.withOpacity(0.5)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ).animate(target: letter.isNotEmpty ? 1 : 0)
           .scale(duration: 150.ms, curve: Curves.easeOutBack),
        );
      }),
    );
  }

  // --- Input Panel (Keyboard, Choices, Scrambled tiles) ---
  Widget _buildInputPanel(ThemeData theme, GameSessionState gameState, WordModel word) {
    if (word.gameMode == GameMode.chooseSpelling) {
      final options = word.options ?? [word.word, '${word.word}e', 'Aple'];
      return Column(
        children: options.map((opt) {
          final isSelected = gameState.selectedMultipleChoiceOption == opt;
          final isCorrect = opt.toUpperCase() == word.word.toUpperCase();
          
          Color cardBg = theme.cardColor;
          Color borderCol = theme.dividerColor.withOpacity(0.1);
          Color textCol = theme.colorScheme.onSurface;

          if (isSelected) {
            if (isCorrect) {
              cardBg = theme.colorScheme.success.withOpacity(0.15);
              borderCol = theme.colorScheme.success;
              textCol = theme.colorScheme.success;
            } else {
              cardBg = theme.colorScheme.error.withOpacity(0.15);
              borderCol = theme.colorScheme.error;
              textCol = theme.colorScheme.error;
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 70),
            child: PopButton(
              backgroundColor: cardBg,
              border: Border.all(color: borderCol, width: 2),
              boxShadow: const [],
              onTap: () => ref.read(gameStateProvider.notifier).chooseOption(opt),
              child: Text(
                opt,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: textCol,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    if (word.gameMode == GameMode.unscramble) {
      // Scrambled letters tiles block
      return Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(_unscramblePool.length, (index) {
              final letter = _unscramblePool[index];
              final bool isUsed = _unscrambleSelectionOrder.contains(index.toString());

              return Opacity(
                opacity: isUsed ? 0.3 : 1.0,
                child: PopButton(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  onTap: isUsed ? null : () => _onUnscrambleTileTap(index, letter),
                  child: Text(
                    letter,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: _resetUnscramble,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset Letters'),
          ),
        ],
      );
    }

    // Default: Missing Letters Keyboard
    return Wrap(
      spacing: 6,
      runSpacing: 6,
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

  // --- Hint System Bar ---
  Widget _buildHintBar(ThemeData theme, GameSessionState gameState) {
    if (gameState.isLevelComplete) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Reveal Letter
        Flexible(
          child: _buildHintButton(
            theme: theme,
            icon: Icons.lightbulb_outline_rounded,
            label: 'Reveal (25⭐)',
            onPressed: () {
              final success = ref.read(gameStateProvider.notifier).useHintRevealLetter();
              if (!success) _showNoStarsMsg(theme);
            },
          ),
        ),
        
        // Remove Wrongs (Only active if keyboard letters are custom or missingLetters/unscramble)
        if (gameState.activeWord?.gameMode != GameMode.chooseSpelling)
          Flexible(
            child: _buildHintButton(
              theme: theme,
              icon: Icons.remove_circle_outline_rounded,
              label: 'Zap (15⭐)',
              onPressed: () {
                final success = ref.read(gameStateProvider.notifier).useHintRemoveWrongLetter(
                  _keyboardLetters,
                  (updated) {
                    setState(() {
                      _keyboardLetters = updated;
                    });
                  },
                );
                if (!success) _showNoStarsMsg(theme);
              },
            ),
          ),
          
        // Skip Level
        Flexible(
          child: _buildHintButton(
            theme: theme,
            icon: Icons.skip_next_rounded,
            label: 'Skip (40⭐)',
            onPressed: () {
              final success = ref.read(gameStateProvider.notifier).useHintSkipWord();
              if (!success) _showNoStarsMsg(theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHintButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label),
      ),
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        textStyle: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showNoStarsMsg(ThemeData theme) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Need more stars?'),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ref.read(adServiceProvider).showRewardedAd(() {
                  ref.read(gameStateProvider.notifier).grantRewardedHint();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Awarded +30 Stars!'),
                      backgroundColor: theme.colorScheme.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }, () {});
              },
              child: Text(
                'Watch Ad (+30⭐)',
                style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // --- Pause Menu Dialog ---
  void _showPauseDialog(ThemeData theme) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Paused', textAlign: TextAlign.center),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow_rounded),
              title: const Text('Resume Play'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: const Text('Restart Level'),
              onTap: () {
                Navigator.pop(context);
                ref.read(gameStateProvider.notifier).retryLevel();
                _initializeKeyboardAndPools();
              },
            ),
            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text('Exit to Home'),
              onTap: () {
                Navigator.pop(context);
                context.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
