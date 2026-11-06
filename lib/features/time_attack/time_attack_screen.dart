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
  Set<String> _disabledKeyboardLetters = {};
  Set<int> _wrongSlotIndices = {};

  @override
  void initState() {
    super.initState();
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
      _disabledKeyboardLetters = {};
      _wrongSlotIndices = {};
    });
  }

  void _onLetterTap(String letter) async {
    final gameState = ref.read(gameStateProvider);
    final word = gameState.activeWord;
    if (word == null) return;

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
      } else {
        ref.read(gameStateProvider.notifier).submitTimeAttackAnswer();
        _initializeInputs();
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

  void _onSlotClear(int slotIndex) {
    final gameState = ref.read(gameStateProvider);
    final word = gameState.activeWord;
    if (word == null) return;

    ref.read(gameStateProvider.notifier).clearLetter(slotIndex);
    setState(() {
      _activeSlotIndex = slotIndex;
      _disabledKeyboardLetters.clear();
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  // 1. TOP STATS BAR (SCORE, CIRCULAR TIMER, HIGH SCORE)
                  _buildHeader(theme, gameState, isDark),

                  const Spacer(flex: 1),

                  // 2. CATEGORY TAG
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.coralPink.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.coralPink.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'CATEGORY: ${word.category.toUpperCase()}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.coralPink,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 3. INSTRUCTION NOTE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurfaceColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'Type fast to earn extra seconds and maximize your score!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // 4. PUZZLE TILES
                  _buildPuzzleArea(theme, gameState, word, isDark)
                      .animate(target: gameState.isWrongAnswerShake ? 1 : 0)
                      .shake(duration: 300.ms, curve: Curves.easeInOut),

                  const Spacer(flex: 2),

                  // 5. KEYBOARD / SELECTION
                  _buildInputPanel(theme, gameState, word, isDark),

                  const Spacer(flex: 2),

                  // 6. QUIT BUTTON
                  TextButton.icon(
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).exitTimeAttack();
                      context.pop();
                    },
                    icon: const Icon(Icons.exit_to_app_rounded, size: 20),
                    label: const Text('Exit Challenge'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

  // --- Header Area ---
  Widget _buildHeader(ThemeData theme, GameSessionState gameState, bool isDark) {
    final bool isCritical = gameState.timeAttackSecondsRemaining <= 10;
    final progress = gameState.timeAttackSecondsRemaining / 60.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Score Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SCORE',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${gameState.timeAttackScore}',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),

        // Glowing Visual Countdown Timer
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isCritical ? AppTheme.errorColor : AppTheme.mintGreen)
                    .withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 66,
                height: 66,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: theme.dividerColor.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCritical ? AppTheme.errorColor : AppTheme.mintGreen,
                  ),
                ),
              ),
              Text(
                '${gameState.timeAttackSecondsRemaining}s',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: isCritical ? AppTheme.errorColor : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        // High Score Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'RECORD',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${gameState.timeAttackHighScore}',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.sunnyYellow,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Puzzle Letters ---
  Widget _buildPuzzleArea(ThemeData theme, GameSessionState gameState, WordModel word, bool isDark) {
    if (word.gameMode == GameMode.chooseSpelling) {
      return Text(
        'Which spelling is correct?',
        style: theme.textTheme.displayMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
        textAlign: TextAlign.center,
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final int wordLength = word.word.length;
    final double spacing = wordLength > 8 ? 6.0 : 8.0;
    final double paddingHorizontal = 40.0;
    final double availableWidth = screenWidth - paddingHorizontal - ((wordLength - 1) * spacing);
    final double calculatedSize = (availableWidth / wordLength).clamp(34.0, 52.0);

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
        final bool isActive = index == _activeSlotIndex;
        final bool isWrong = _wrongSlotIndices.contains(index);

        Color borderCol = isDark
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xffe2e8f0);
        Color bgCol = isDark ? AppTheme.darkSurfaceColor : Colors.white;

        if (isWrong) {
          borderCol = AppTheme.errorColor;
          bgCol = AppTheme.errorColor.withValues(alpha: 0.15);
        } else if (isActive) {
          borderCol = AppTheme.coralPink;
          bgCol = AppTheme.coralPink.withValues(alpha: 0.1);
        } else if (isPrefilled) {
          bgCol = isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xfff1f5f9);
        }

        return GestureDetector(
          onTap: () => _onSlotClear(index),
          child: Container(
            width: calculatedSize,
            height: calculatedSize * 1.2,
            decoration: BoxDecoration(
              color: bgCol,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderCol,
                width: isWrong ? 2.5 : (isActive ? 2.5 : 2.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              isEmpty ? '' : letter,
              style: theme.textTheme.displayMedium?.copyWith(
                fontSize: calculatedSize * 0.5,
                fontWeight: FontWeight.w800,
                color: isWrong
                    ? AppTheme.errorColor
                    : (isPrefilled
                        ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)
                        : theme.colorScheme.onSurface),
              ),
            ),
          ),
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
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: double.infinity,
            child: PopButton(
              backgroundColor: isDark ? AppTheme.darkSurfaceColor : Colors.white,
              depth: 3.5,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5),
              onTap: () {
                ref.read(gameStateProvider.notifier).chooseOption(opt);
                ref.read(gameStateProvider.notifier).submitTimeAttackAnswer();
              },
              child: Text(
                opt,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }).toList(),
      );
    }

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
                ? (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xfff1f5f9))
                : (isDark ? AppTheme.darkSurfaceColor : Colors.white),
            padding: EdgeInsets.zero,
            border: Border.all(
              color: isDisabled
                  ? Colors.transparent
                  : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xffe2e8f0)),
              width: 1.2,
            ),
            shadowColor: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xffcbd5e1),
            onTap: isDisabled ? null : () => _onLetterTap(letter),
            child: Text(
              letter,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDisabled
                    ? (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.25))
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- 2025 Modern Rounded Game Over Overlay ---
  Widget _buildGameOverOverlay(ThemeData theme, GameSessionState gameState, bool isDark) {
    final bool isNewHigh =
        gameState.timeAttackScore >= gameState.timeAttackHighScore && gameState.timeAttackScore > 0;

    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.coralPink.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_off_rounded,
                  color: AppTheme.coralPink,
                  size: 48,
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'TIME\'S UP!',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: AppTheme.coralPink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fast spelling run complete!',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              if (isNewHigh)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.sunnyYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.sunnyYellow.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events_rounded,
                          color: AppTheme.sunnyYellow, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'NEW HIGH SCORE! 🏆',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xffb45309),
                          fontWeight: FontWeight.w900,
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
                      const SizedBox(height: 2),
                      Text(
                        '${gameState.timeAttackScore}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                      width: 1.5,
                      height: 40,
                      color: theme.dividerColor.withValues(alpha: 0.15)),
                  Column(
                    children: [
                      Text('High Score', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${gameState.timeAttackHighScore}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.sunnyYellow,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 26),

              if (!_hasContinued) ...[
                PopButton(
                  backgroundColor: AppTheme.sunnyYellow,
                  depth: 4.5,
                  shadowColor: const Color(0xffd97706),
                  onTap: () {
                    ref.read(adServiceProvider).showRewardedAd(() {
                      ref.read(gameStateProvider.notifier).continueTimeAttack();
                      setState(() => _hasContinued = true);
                    }, () {});
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_library_rounded, color: Color(0xff78350f), size: 22),
                      SizedBox(width: 8),
                      Text(
                        'CONTINUE (+30s)',
                        style: TextStyle(
                          color: Color(0xff78350f),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              PopButton(
                backgroundColor: AppTheme.primaryColor,
                depth: 4.5,
                shadowColor: const Color(0xff4338ca),
                onTap: () {
                  ref.read(gameStateProvider.notifier).startTimeAttack();
                  _initializeInputs();
                  setState(() => _hasContinued = false);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.replay_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'PLAY AGAIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  ref.read(gameStateProvider.notifier).exitTimeAttack();
                  context.go('/home');
                },
                child: Text(
                  'Exit to Main Menu',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
