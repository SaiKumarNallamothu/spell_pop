class ProgressModel {
  final int currentLevel;
  final int stars;
  final List<int> completedLevels;
  final int streak;
  final int highScore;
  final String lastActiveDate;

  ProgressModel({
    required this.currentLevel,
    required this.stars,
    required this.completedLevels,
    required this.streak,
    required this.highScore,
    required this.lastActiveDate,
  });

  ProgressModel copyWith({
    int? currentLevel,
    int? stars,
    List<int>? completedLevels,
    int? streak,
    int? highScore,
    String? lastActiveDate,
  }) {
    return ProgressModel(
      currentLevel: currentLevel ?? this.currentLevel,
      stars: stars ?? this.stars,
      completedLevels: completedLevels ?? this.completedLevels,
      streak: streak ?? this.streak,
      highScore: highScore ?? this.highScore,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}
