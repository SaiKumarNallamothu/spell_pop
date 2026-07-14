enum Difficulty { easy, medium, hard, expert }

enum GameMode { missingLetters, unscramble, chooseSpelling, timeAttack }

class WordModel {
  final int id;
  final String word;
  final String category;
  final Difficulty difficulty;
  final GameMode gameMode;
  final List<String>? options; // For choose correct spelling

  WordModel({
    required this.id,
    required this.word,
    required this.category,
    required this.difficulty,
    required this.gameMode,
    this.options,
  });

  String get difficultyName {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
    }
  }

  String get gameModeName {
    switch (gameMode) {
      case GameMode.missingLetters:
        return 'Missing Letters';
      case GameMode.unscramble:
        return 'Unscramble';
      case GameMode.chooseSpelling:
        return 'Choose Spelling';
      case GameMode.timeAttack:
        return 'Time Attack';
    }
  }

  factory WordModel.fromJson(Map<String, dynamic> json) {
    Difficulty diff;
    switch (json['difficulty']?.toString().toLowerCase()) {
      case 'medium':
        diff = Difficulty.medium;
        break;
      case 'hard':
        diff = Difficulty.hard;
        break;
      case 'expert':
        diff = Difficulty.expert;
        break;
      default:
        diff = Difficulty.easy;
    }

    GameMode mode;
    switch (json['gameMode']?.toString()) {
      case 'unscramble':
        mode = GameMode.unscramble;
        break;
      case 'chooseSpelling':
        mode = GameMode.chooseSpelling;
        break;
      case 'timeAttack':
        mode = GameMode.timeAttack;
        break;
      default:
        mode = GameMode.missingLetters;
    }

    return WordModel(
      id: json['id'] as int,
      word: json['word'] as String,
      category: json['category'] as String,
      difficulty: diff,
      gameMode: mode,
      options: json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }
}
