import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/services_provider.dart';
import '../../../models/word_model.dart';

class GameSessionState {
  final int currentLevel;
  final int stars;
  final List<int> completedLevels;
  final int streak;
  final int timeAttackHighScore;
  
  // Current Active Puzzle
  final WordModel? activeWord;
  final List<String> userAnswerLetters; // Letters filled in by player for Missing Letters / Unscramble
  final String? selectedMultipleChoiceOption; // For choose spelling
  final bool isLevelComplete;
  final bool isWrongAnswerShake;
  
  // Time Attack Mode variables
  final int timeAttackScore;
  final int timeAttackSecondsRemaining;
  final bool isTimeAttackActive;
  final bool isTimeAttackOver;

  GameSessionState({
    required this.currentLevel,
    required this.stars,
    required this.completedLevels,
    required this.streak,
    required this.timeAttackHighScore,
    this.activeWord,
    required this.userAnswerLetters,
    this.selectedMultipleChoiceOption,
    required this.isLevelComplete,
    required this.isWrongAnswerShake,
    required this.timeAttackScore,
    required this.timeAttackSecondsRemaining,
    required this.isTimeAttackActive,
    required this.isTimeAttackOver,
  });

  GameSessionState copyWith({
    int? currentLevel,
    int? stars,
    List<int>? completedLevels,
    int? streak,
    int? timeAttackHighScore,
    WordModel? activeWord,
    List<String>? userAnswerLetters,
    String? selectedMultipleChoiceOption,
    bool? isLevelComplete,
    bool? isWrongAnswerShake,
    int? timeAttackScore,
    int? timeAttackSecondsRemaining,
    bool? isTimeAttackActive,
    bool? isTimeAttackOver,
  }) {
    return GameSessionState(
      currentLevel: currentLevel ?? this.currentLevel,
      stars: stars ?? this.stars,
      completedLevels: completedLevels ?? this.completedLevels,
      streak: streak ?? this.streak,
      timeAttackHighScore: timeAttackHighScore ?? this.timeAttackHighScore,
      activeWord: activeWord ?? this.activeWord,
      userAnswerLetters: userAnswerLetters ?? this.userAnswerLetters,
      selectedMultipleChoiceOption: selectedMultipleChoiceOption ?? this.selectedMultipleChoiceOption,
      isLevelComplete: isLevelComplete ?? this.isLevelComplete,
      isWrongAnswerShake: isWrongAnswerShake ?? this.isWrongAnswerShake,
      timeAttackScore: timeAttackScore ?? this.timeAttackScore,
      timeAttackSecondsRemaining: timeAttackSecondsRemaining ?? this.timeAttackSecondsRemaining,
      isTimeAttackActive: isTimeAttackActive ?? this.isTimeAttackActive,
      isTimeAttackOver: isTimeAttackOver ?? this.isTimeAttackOver,
    );
  }
}

class GameSessionNotifier extends Notifier<GameSessionState> {
  Timer? _timeAttackTimer;

  @override
  GameSessionState build() {
    ref.onDispose(() {
      _timeAttackTimer?.cancel();
    });

    final db = ref.watch(databaseServiceProvider);
    final currentLevel = db.getCurrentLevel();
    final stars = db.getStars();
    final completedLevels = db.getCompletedLevels();
    final streak = db.getDailyStreak();
    final highScore = db.getTimeAttackHighScore();

    // Default active word setup
    final wordIndex = (currentLevel - 1) % (db.words.isEmpty ? 1 : db.words.length);
    final word = db.words.isNotEmpty ? db.words[wordIndex] : null;

    List<String> answerLetters = [];
    if (word != null) {
      if (word.gameMode == GameMode.missingLetters) {
        answerLetters = List.filled(word.word.length, '');
        final rand = Random();
        final indicesToReveal = <int>{};
        final countToReveal = (word.word.length / 2).ceil();
        while (indicesToReveal.length < countToReveal) {
          indicesToReveal.add(rand.nextInt(word.word.length));
        }
        for (var idx in indicesToReveal) {
          answerLetters[idx] = word.word[idx];
        }
      } else {
        answerLetters = List.filled(word.word.length, '');
      }
    }

    return GameSessionState(
      currentLevel: currentLevel,
      stars: stars,
      completedLevels: completedLevels,
      streak: streak,
      timeAttackHighScore: highScore,
      activeWord: word,
      userAnswerLetters: answerLetters,
      selectedMultipleChoiceOption: null,
      isLevelComplete: false,
      isWrongAnswerShake: false,
      timeAttackScore: 0,
      timeAttackSecondsRemaining: 60,
      isTimeAttackActive: false,
      isTimeAttackOver: false,
    );
  }

  void _saveProgress() {
    final db = ref.read(databaseServiceProvider);
    db.setCurrentLevel(state.currentLevel);
    db.setStars(state.stars);
    db.setDailyStreak(state.streak);
    db.setTimeAttackHighScore(state.timeAttackHighScore);
  }

  void setupLevel(int levelIndex) {
    final db = ref.read(databaseServiceProvider);
    if (db.words.isEmpty) return;
    
    final wordIndex = (levelIndex - 1) % db.words.length;
    final word = db.words[wordIndex];
    
    List<String> answerLetters = [];
    if (word.gameMode == GameMode.missingLetters) {
      answerLetters = List.filled(word.word.length, '');
      final rand = Random();
      final indicesToReveal = <int>{};
      final countToReveal = (word.word.length / 2).ceil();
      while (indicesToReveal.length < countToReveal) {
        indicesToReveal.add(rand.nextInt(word.word.length));
      }
      for (var idx in indicesToReveal) {
        answerLetters[idx] = word.word[idx];
      }
    } else {
      answerLetters = List.filled(word.word.length, '');
    }

    state = state.copyWith(
      currentLevel: levelIndex,
      activeWord: word,
      userAnswerLetters: answerLetters,
      selectedMultipleChoiceOption: null,
      isLevelComplete: false,
      isWrongAnswerShake: false,
    );
  }

  void fillLetter(int slotIndex, String letter) {
    if (state.activeWord == null || state.isLevelComplete) return;

    final updatedLetters = List<String>.from(state.userAnswerLetters);
    updatedLetters[slotIndex] = letter.toUpperCase();

    state = state.copyWith(userAnswerLetters: updatedLetters);

    ref.read(audioServiceProvider).playClickSound();

    if (!updatedLetters.contains('')) {
      checkAnswer();
    }
  }

  void clearLetter(int slotIndex) {
    if (state.activeWord == null || state.isLevelComplete) return;

    final updatedLetters = List<String>.from(state.userAnswerLetters);
    updatedLetters[slotIndex] = '';
    state = state.copyWith(userAnswerLetters: updatedLetters);

    ref.read(audioServiceProvider).playClickSound();
  }

  void chooseOption(String option) {
    if (state.activeWord == null || state.isLevelComplete) return;
    
    state = state.copyWith(selectedMultipleChoiceOption: option);
    ref.read(audioServiceProvider).playClickSound();
    checkAnswer();
  }

  void checkAnswer() {
    final word = state.activeWord;
    if (word == null || state.isLevelComplete) return;

    bool isCorrect = false;

    if (word.gameMode == GameMode.chooseSpelling) {
      isCorrect = state.selectedMultipleChoiceOption?.toUpperCase() == word.word.toUpperCase();
    } else {
      final answer = state.userAnswerLetters.join();
      isCorrect = answer.toUpperCase() == word.word.toUpperCase();
    }

    if (isCorrect) {
      ref.read(audioServiceProvider).playCorrectSound();

      final db = ref.read(databaseServiceProvider);
      db.addCompletedLevel(state.currentLevel);

      final List<int> updatedCompleted = List<int>.from(state.completedLevels);
      if (!updatedCompleted.contains(state.currentLevel)) {
        updatedCompleted.add(state.currentLevel);
      }
      
      final streakMultiplier = 1 + (state.streak ~/ 5) * 0.1;
      final starsEarned = (10 * streakMultiplier).round();

      state = state.copyWith(
        isLevelComplete: true,
        completedLevels: updatedCompleted,
        stars: state.stars + starsEarned,
        streak: state.streak + 1,
      );
      _saveProgress();

      // Show Interstitial ad after every 8 completed levels
      if (state.currentLevel % 8 == 0) {
        ref.read(adServiceProvider).showInterstitialAd(() {
          // Ad complete handler
        });
      }
    } else {
      ref.read(audioServiceProvider).playWrongSound();

      state = state.copyWith(isWrongAnswerShake: true);
      Future.delayed(const Duration(milliseconds: 300), () {
        state = state.copyWith(isWrongAnswerShake: false);
      });
      state = state.copyWith(streak: 0);
    }
  }

  bool useHintRevealLetter() {
    final word = state.activeWord;
    if (word == null || state.isLevelComplete || state.stars < 25) return false;

    if (word.gameMode == GameMode.chooseSpelling) return false;

    int indexToReveal = -1;
    for (int i = 0; i < word.word.length; i++) {
      if (state.userAnswerLetters[i] != word.word[i]) {
        indexToReveal = i;
        break;
      }
    }

    if (indexToReveal != -1) {
      fillLetter(indexToReveal, word.word[indexToReveal]);
      state = state.copyWith(stars: state.stars - 25);
      _saveProgress();
      return true;
    }
    return false;
  }

  bool useHintRemoveWrongLetter(List<String> keyboardLetters, Function(List<String>) onUpdatedKeyboard) {
    final word = state.activeWord;
    if (word == null || state.isLevelComplete || state.stars < 15) return false;

    final wrongKeyboardLetters = keyboardLetters
        .where((l) => !word.word.toUpperCase().contains(l.toUpperCase()))
        .toList();

    if (wrongKeyboardLetters.isNotEmpty) {
      final rand = Random();
      final lettersToRemove = <String>[];
      for (int i = 0; i < min(3, wrongKeyboardLetters.length); i++) {
        final randomLetter = wrongKeyboardLetters[rand.nextInt(wrongKeyboardLetters.length)];
        lettersToRemove.add(randomLetter);
        wrongKeyboardLetters.remove(randomLetter);
      }

      final updatedKeyboard = keyboardLetters.where((l) => !lettersToRemove.contains(l)).toList();
      onUpdatedKeyboard(updatedKeyboard);

      state = state.copyWith(stars: state.stars - 15);
      _saveProgress();
      return true;
    }
    return false;
  }

  bool useHintSkipWord() {
    if (state.activeWord == null || state.isLevelComplete || state.stars < 40) return false;

    state = state.copyWith(
      stars: state.stars - 40,
      isLevelComplete: true,
    );
    _saveProgress();
    return true;
  }

  void nextLevel() {
    setupLevel(state.currentLevel + 1);
  }

  void retryLevel() {
    setupLevel(state.currentLevel);
  }

  void startTimeAttack() {
    _timeAttackTimer?.cancel();
    
    final db = ref.read(databaseServiceProvider);
    final rand = Random();
    final randomWord = db.words[rand.nextInt(db.words.length)];

    state = state.copyWith(
      isTimeAttackActive: true,
      isTimeAttackOver: false,
      timeAttackScore: 0,
      timeAttackSecondsRemaining: 60,
      activeWord: randomWord,
      userAnswerLetters: List.filled(randomWord.word.length, ''),
      selectedMultipleChoiceOption: null,
      isLevelComplete: false,
    );

    _startTimeAttackTimerLoop();
  }

  void _startTimeAttackTimerLoop() {
    _timeAttackTimer?.cancel();
    _timeAttackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeAttackSecondsRemaining <= 1) {
        timer.cancel();
        final bool isNewHighScore = state.timeAttackScore > state.timeAttackHighScore;
        final int updatedHighScore = isNewHighScore ? state.timeAttackScore : state.timeAttackHighScore;
        final int bonusStars = isNewHighScore ? 50 : (state.timeAttackScore * 2);

        state = state.copyWith(
          isTimeAttackOver: true,
          timeAttackHighScore: updatedHighScore,
          stars: state.stars + bonusStars,
        );
        _saveProgress();
      } else {
        state = state.copyWith(
          timeAttackSecondsRemaining: state.timeAttackSecondsRemaining - 1,
        );
      }
    });
  }

  void continueTimeAttack() {
    state = state.copyWith(
      isTimeAttackOver: false,
      timeAttackSecondsRemaining: 30,
    );
    _startTimeAttackTimerLoop();
  }

  void submitTimeAttackAnswer() {
    final word = state.activeWord;
    if (word == null || state.isTimeAttackOver) return;

    bool isCorrect = false;
    if (word.gameMode == GameMode.chooseSpelling) {
      isCorrect = state.selectedMultipleChoiceOption?.toUpperCase() == word.word.toUpperCase();
    } else {
      isCorrect = state.userAnswerLetters.join().toUpperCase() == word.word.toUpperCase();
    }

    if (isCorrect) {
      ref.read(audioServiceProvider).playCorrectSound();

      final db = ref.read(databaseServiceProvider);
      final rand = Random();
      final randomWord = db.words[rand.nextInt(db.words.length)];

      state = state.copyWith(
        timeAttackScore: state.timeAttackScore + 1,
        timeAttackSecondsRemaining: min(60, state.timeAttackSecondsRemaining + 2),
        activeWord: randomWord,
        userAnswerLetters: List.filled(randomWord.word.length, ''),
        selectedMultipleChoiceOption: null,
      );
    } else {
      ref.read(audioServiceProvider).playWrongSound();

      state = state.copyWith(
        isWrongAnswerShake: true,
        timeAttackSecondsRemaining: max(0, state.timeAttackSecondsRemaining - 3),
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        state = state.copyWith(isWrongAnswerShake: false);
      });
    }
  }

  void exitTimeAttack() {
    _timeAttackTimer?.cancel();
    state = state.copyWith(
      isTimeAttackActive: false,
      isTimeAttackOver: false,
    );
    setupLevel(state.currentLevel);
  }

  void completeDailyPuzzle() {
    state = state.copyWith(
      stars: state.stars + 50,
      streak: state.streak + 1,
    );
    _saveProgress();
  }

  void grantRewardedHint() {
    state = state.copyWith(stars: state.stars + 30);
    _saveProgress();
  }

  void doubleDailyReward() {
    state = state.copyWith(stars: state.stars + 50);
    _saveProgress();
  }
}

final gameStateProvider = NotifierProvider<GameSessionNotifier, GameSessionState>(GameSessionNotifier.new);
