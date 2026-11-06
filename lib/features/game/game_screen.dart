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
  Set<String> _disabledKeyboardLetters = {};
  Set<int> _wrongSlotIndices = {};

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
      final letters = word.word.split('');
      final rand = Random();
      int attempt = 0;
      do {
        letters.shuffle(rand);
        attempt++;
      } while (letters.join() == word.word && attempt < 10);

      setState(() {
        _unscramblePool = List<String>.from(letters);
        _unscrambleSelectionOrder = [];
        _activeSlotIndex = 0;
        _disabledKeyboardLetters = {};
        _wrongSlotIndices = {};
      });
    } else if (word.gameMode == GameMode.missingLetters) {
      int firstEmpty = gameState.userAnswerLetters.indexOf('');
      setState(() {
        _activeSlotIndex = firstEmpty != -1 ? firstEmpty : 0;
        _keyboardLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
        _disabledKeyboardLetters = {};
        _wrongSlotIndices = {};
      });
    }
  }

  void _onLetterTap(String letter) async {
    final gameState = ref.read(gameStateProvider);
    final word = gameState.activeWord;
    if (word == null) return;

    if (word.gameMode == GameMode.missingLetters) {
      final correctLetter = word.word[_activeSlotIndex].toUpperCase();
      if (letter.toUpperCase() == correctLetter) {
        ref.read(gameStateProvider.notifier).fillLetter(_activeSlotIndex, letter);

        setState(() {
          _disabledKeyboardLetters.clear();
        });

        final updatedLetters = ref.read(gameStateProvider).userAnswerLetters;
        int nextEmpty = updatedLetters.indexOf('', _activeSlotIndex + 1);
        if (nextEmpty == -1) {
          nextEmpty = updatedLetters.indexOf('');
        }

        if (nextEmpty != -1) {
          setState(() {
            _activeSlotIndex = nextEmpty;
          });
        }
      } else {
        final wrongIndex = _activeSlotIndex;
        ref.read(gameStateProvider.notifier).fillLetter(wrongIndex, letter);
        setState(() {
          _wrongSlotIndices.add(wrongIndex);
        });

        ref.read(audioServiceProvider).playWrongSound();
        ref.read(gameStateProvider.notifier).triggerWrongAnswerShake();

        await Future.delayed(const Duration(milliseconds: 600));

        if (mounted) {
          ref.read(gameStateProvider.notifier).clearLetter(wrongIndex);
          setState(() {
            _wrongSlotIndices.remove(wrongIndex);
            _disabledKeyboardLetters.add(letter.toUpperCase());
          });
        }
      }
    }
  }

  void _onUnscrambleTileTap(int poolIndex, String letter) async {
    final gameState = ref.read(gameStateProvider);
    final word = gameState.activeWord;
    if (word == null || gameState.isLevelComplete) return;

    final firstEmptyIdx = gameState.userAnswerLetters.indexOf('');
    if (firstEmptyIdx != -1) {
      final correctLetter = word.word[firstEmptyIdx].toUpperCase();
      if (letter.toUpperCase() == correctLetter) {
        ref.read(gameStateProvider.notifier).fillLetter(firstEmptyIdx, letter);

        setState(() {
          _unscrambleSelectionOrder.add(poolIndex.toString());

          final updatedLetters = ref.read(gameStateProvider).userAnswerLetters;
          final nextEmpty = updatedLetters.indexOf('');
          _activeSlotIndex = nextEmpty != -1 ? nextEmpty : 0;
        });
      } else {
        final wrongIndex = firstEmptyIdx;
        ref.read(gameStateProvider.notifier).fillLetter(wrongIndex, letter);
        setState(() {
          _wrongSlotIndices.add(wrongIndex);
        });

        ref.read(audioServiceProvider).playWrongSound();
        ref.read(gameStateProvider.notifier).triggerWrongAnswerShake();

        await Future.delayed(const Duration(milliseconds: 600));

        if (mounted) {
          ref.read(gameStateProvider.notifier).clearLetter(wrongIndex);
          setState(() {
            _wrongSlotIndices.remove(wrongIndex);
          });
        }
      }
    }
  }

  void _onSlotClear(int slotIndex) {
    final gameState = ref.read(gameStateProvider);
    final word = gameState.activeWord;
    if (word == null || gameState.isLevelComplete) return;

    if (word.gameMode == GameMode.missingLetters) {
      if (word.word[slotIndex] != gameState.userAnswerLetters[slotIndex]) {
        ref.read(gameStateProvider.notifier).clearLetter(slotIndex);
        setState(() {
          _activeSlotIndex = slotIndex;
          _disabledKeyboardLetters.clear();
        });
      }
    } else if (word.gameMode == GameMode.unscramble) {
      final letter = gameState.userAnswerLetters[slotIndex];
      if (letter.isNotEmpty) {
        ref.read(gameStateProvider.notifier).clearLetter(slotIndex);
        if (_unscrambleSelectionOrder.isNotEmpty) {
          _unscrambleSelectionOrder.removeLast();
        }
        setState(() {
          _activeSlotIndex = slotIndex;
        });
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
    final isDark = theme.brightness == Brightness.dark;

    final gameState = ref.watch(gameStateProvider);
    final word = gameState.activeWord;

    if (word == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient soft background bubbles
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppTheme.primaryColor.withValues(alpha: 0.12)
                    : AppTheme.pastelLavender,
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppTheme.sunnyYellow.withValues(alpha: 0.08)
                    : AppTheme.pastelSky,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  // 1. TOP HEADER ACTION BAR
                  _buildHeader(theme, gameState, isDark),

                  const Spacer(flex: 1),

                  // 2. CATEGORY PILL BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.category_rounded,
                          color: AppTheme.primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          word.category.toUpperCase(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. INSTRUCTION CARD WITH MODERN ROUNDED CORNERS
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurfaceColor.withValues(alpha: 0.8)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.08),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.coralPink.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            word.gameMode == GameMode.missingLetters
                                ? Icons.edit_note_rounded
                                : word.gameMode == GameMode.unscramble
                                    ? Icons.shuffle_rounded
                                    : Icons.touch_app_rounded,
                            color: AppTheme.coralPink,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            word.gameMode == GameMode.missingLetters
                                ? 'Tap the missing letters below to finish spelling!'
                                : word.gameMode == GameMode.unscramble
                                    ? 'Pop the letter bubbles in the right order!'
                                    : 'Select the correctly spelled word!',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // 4. PUZZLE WORD TILES
                  _buildPuzzleArea(theme, gameState, word, isDark)
                      .animate(target: gameState.isWrongAnswerShake ? 1 : 0)
                      .shake(duration: 350.ms, curve: Curves.easeInOut),

                  const Spacer(flex: 2),

                  // 5. INPUT PANEL (KEYBOARD / OPTIONS / SCRAMBLE BUBBLES)
                  _buildInputPanel(theme, gameState, word, isDark),

                  const Spacer(flex: 1),

                  // 6. HINTS TOOLBAR
                  _buildHintBar(theme, gameState, isDark),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // 7. CELEBRATION OVERLAY
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

  // --- Top Navigation Header ---
  Widget _buildHeader(ThemeData theme, GameSessionState gameState, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Pause Button with rounded 3D container
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.pause_rounded, size: 24),
            color: AppTheme.primaryColor,
            onPressed: () => _showPauseDialog(theme, isDark),
          ),
        ),

        // Level Title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            'LEVEL ${gameState.currentLevel}',
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Stars Counter Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.sunnyYellow.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.sunnyYellow.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: AppTheme.sunnyYellow, size: 20),
              const SizedBox(width: 4),
              Text(
                '${gameState.stars}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xffb45309),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Puzzle Area (Spell Pop Letter Tiles) ---
  Widget _buildPuzzleArea(ThemeData theme, GameSessionState gameState, WordModel word, bool isDark) {
    if (word.gameMode == GameMode.chooseSpelling) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          'Which spelling is correct?',
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final int wordLength = word.word.length;
    final double spacing = wordLength > 8 ? 6.0 : 10.0;
    final double paddingHorizontal = 40.0;
    final double availableWidth = screenWidth - paddingHorizontal - ((wordLength - 1) * spacing);
    final double calculatedSize = (availableWidth / wordLength).clamp(36.0, 56.0);

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: List.generate(wordLength, (index) {
        final letter = gameState.userAnswerLetters[index];
        final bool isEmpty = letter.isEmpty;
        final bool isPrefilled = word.gameMode == GameMode.missingLetters &&
            word.word[index] == letter &&
            !isEmpty;
        final bool isActive = (word.gameMode == GameMode.missingLetters ||
                word.gameMode == GameMode.unscramble) &&
            index == _activeSlotIndex;
        final bool isWrong = _wrongSlotIndices.contains(index);

        Color borderCol = isDark
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xffe2e8f0);
        Color bgCol = isDark ? AppTheme.darkSurfaceColor : Colors.white;
        Color textCol = theme.colorScheme.onSurface;

        if (isWrong) {
          borderCol = AppTheme.errorColor;
          bgCol = AppTheme.errorColor.withValues(alpha: 0.15);
          textCol = AppTheme.errorColor;
        } else if (isActive) {
          borderCol = AppTheme.primaryColor;
          bgCol = AppTheme.primaryColor.withValues(alpha: 0.1);
          textCol = AppTheme.primaryColor;
        } else if (isPrefilled) {
          bgCol = isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xfff1f5f9);
          textCol = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey;
        } else if (!isEmpty) {
          bgCol = isDark ? AppTheme.darkSurfaceColor : Colors.white;
          borderCol = AppTheme.mintGreen;
          textCol = AppTheme.mintGreen;
        }

        return GestureDetector(
          onTap: () => _onSlotClear(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: calculatedSize,
            height: calculatedSize * 1.22,
            decoration: BoxDecoration(
              color: bgCol,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderCol,
                width: isWrong ? 2.5 : (isActive ? 2.5 : 2.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: isWrong
                      ? AppTheme.errorColor.withValues(alpha: 0.25)
                      : (isActive
                          ? AppTheme.primaryColor.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05)),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              isEmpty ? '' : letter,
              style: theme.textTheme.displayMedium?.copyWith(
                fontSize: calculatedSize * 0.52,
                fontWeight: FontWeight.w800,
                color: textCol,
              ),
            ),
          ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
        );
      }),
    );
  }

  // --- Input Panel ---
  Widget _buildInputPanel(ThemeData theme, GameSessionState gameState, WordModel word, bool isDark) {
    if (word.gameMode == GameMode.chooseSpelling) {
      final options = word.options ?? [word.word, '${word.word}e', 'Aple'];
      return Column(
        children: options.map((opt) {
          final isSelected = gameState.selectedMultipleChoiceOption == opt;
          final isCorrect = opt.toUpperCase() == word.word.toUpperCase();

          Color cardBg = isDark ? AppTheme.darkSurfaceColor : Colors.white;
          Color borderCol = isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xffe2e8f0);
          Color textCol = theme.colorScheme.onSurface;

          if (isSelected) {
            if (isCorrect) {
              cardBg = AppTheme.mintGreen.withValues(alpha: 0.2);
              borderCol = AppTheme.mintGreen;
              textCol = AppTheme.mintGreen;
            } else {
              cardBg = AppTheme.errorColor.withValues(alpha: 0.2);
              borderCol = AppTheme.errorColor;
              textCol = AppTheme.errorColor;
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            width: double.infinity,
            child: PopButton(
              backgroundColor: cardBg,
              depth: 4,
              shadowColor: borderCol.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderCol, width: 2),
              onTap: () => ref.read(gameStateProvider.notifier).chooseOption(opt),
              child: Text(
                opt,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: textCol,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }).toList(),
      );
    }

    if (word.gameMode == GameMode.unscramble) {
      // 3D Letter Bubbles
      return Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(_unscramblePool.length, (index) {
              final letter = _unscramblePool[index];
              final bool isUsed = _unscrambleSelectionOrder.contains(index.toString());

              return Visibility(
                visible: !isUsed,
                child: PopButton(
                  backgroundColor: AppTheme.primaryColor,
                  depth: 4.5,
                  shadowColor: const Color(0xff4338ca),
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  onTap: () => _onUnscrambleTileTap(index, letter),
                  child: Text(
                    letter,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Reset button
          TextButton.icon(
            onPressed: _resetUnscramble,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text('Reset Letters'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              textStyle: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }

    // Default missing letters custom keyboard
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: _keyboardLetters.map((letter) {
        final bool isDisabled = _disabledKeyboardLetters.contains(letter.toUpperCase());
        return SizedBox(
          width: 33,
          height: 48,
          child: PopButton(
            alignment: Alignment.center,
            depth: isDisabled ? 0 : 3,
            borderRadius: BorderRadius.circular(12),
            backgroundColor: isDisabled
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xfff1f5f9))
                : (isDark ? AppTheme.darkSurfaceColor : Colors.white),
            padding: EdgeInsets.zero,
            border: Border.all(
              color: isDisabled
                  ? Colors.transparent
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xffe2e8f0)),
              width: 1.2,
            ),
            shadowColor: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : const Color(0xffcbd5e1),
            onTap: isDisabled ? null : () => _onLetterTap(letter),
            child: Text(
              letter,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDisabled
                    ? (isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.25))
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- Hints Toolbar ---
  Widget _buildHintBar(ThemeData theme, GameSessionState gameState, bool isDark) {
    if (gameState.isLevelComplete) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reveal Letter
          _buildHintButton(
            theme: theme,
            icon: Icons.lightbulb_rounded,
            accentColor: AppTheme.sunnyYellow,
            label: 'Reveal (25⭐)',
            onPressed: () {
              final success = ref.read(gameStateProvider.notifier).useHintRevealLetter();
              if (!success) _showNoStarsMsg(theme);
            },
          ),

          Container(
            height: 24,
            width: 1.2,
            color: theme.dividerColor.withValues(alpha: 0.12),
          ),

          // Zap Letter
          if (gameState.activeWord?.gameMode != GameMode.chooseSpelling) ...[
            _buildHintButton(
              theme: theme,
              icon: Icons.bolt_rounded,
              accentColor: AppTheme.coralPink,
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
            Container(
              height: 24,
              width: 1.2,
              color: theme.dividerColor.withValues(alpha: 0.12),
            ),
          ],

          // Skip Level
          _buildHintButton(
            theme: theme,
            icon: Icons.skip_next_rounded,
            accentColor: AppTheme.tealAccent,
            label: 'Skip (40⭐)',
            onPressed: () {
              final success = ref.read(gameStateProvider.notifier).useHintSkipWord();
              if (!success) _showNoStarsMsg(theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHintButton({
    required ThemeData theme,
    required IconData icon,
    required Color accentColor,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accentColor, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
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
                      content: const Text('Awarded +30 Stars! 🎉'),
                      backgroundColor: theme.colorScheme.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }, () {});
              },
              child: Text(
                'Watch Video (+30⭐)',
                style: TextStyle(
                  color: AppTheme.sunnyYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // --- 2025 Modern Rounded Pause Menu ---
  void _showPauseDialog(ThemeData theme, bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryGradientEnd],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.pause_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 18),
              Text(
                'Game Paused',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a breath or try another round!',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Resume button
              PopButton(
                backgroundColor: AppTheme.mintGreen,
                depth: 4,
                shadowColor: const Color(0xff059669),
                onTap: () => Navigator.pop(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text('RESUME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Restart button
              PopButton(
                backgroundColor: AppTheme.sunnyYellow,
                depth: 4,
                shadowColor: const Color(0xffd97706),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(gameStateProvider.notifier).retryLevel();
                  _initializeKeyboardAndPools();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.replay_rounded, color: Color(0xff78350f), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'RESTART LEVEL',
                      style: TextStyle(color: Color(0xff78350f), fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Exit to Home
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/home');
                },
                child: Text(
                  'Exit to Main Menu',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
