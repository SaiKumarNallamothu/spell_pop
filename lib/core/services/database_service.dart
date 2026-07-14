import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/word_model.dart';

class DatabaseService {
  final SharedPreferences _prefs;
  List<WordModel> wordsList = [];

  DatabaseService(this._prefs);

  Future<void> init() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/words/words.json');
      final List<dynamic> list = jsonDecode(jsonStr);
      wordsList = list.map((item) => WordModel.fromJson(item)).toList();
    } catch (e) {
      wordsList = [];
    }
  }

  List<WordModel> get words => wordsList;

  List<WordModel> getWordsByCategory(String category) {
    return wordsList.where((w) => w.category.toLowerCase() == category.toLowerCase()).toList();
  }

  WordModel? getWordById(int id) {
    try {
      return wordsList.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  int getCurrentLevel() => _prefs.getInt('currentLevel') ?? 1;
  Future<void> setCurrentLevel(int level) => _prefs.setInt('currentLevel', level);

  int getStars() => _prefs.getInt('stars') ?? 100;
  Future<void> setStars(int stars) => _prefs.setInt('stars', stars);

  List<int> getCompletedLevels() {
    final list = _prefs.getStringList('completedLevels') ?? [];
    return list.map((e) => int.parse(e)).toList();
  }

  Future<void> addCompletedLevel(int id) async {
    final completed = getCompletedLevels();
    if (!completed.contains(id)) {
      completed.add(id);
      await _prefs.setStringList('completedLevels', completed.map((e) => e.toString()).toList());
    }
  }

  int getDailyStreak() => _prefs.getInt('dailyStreak') ?? 0;
  Future<void> setDailyStreak(int streak) => _prefs.setInt('dailyStreak', streak);

  String? getLastPlayDate() => _prefs.getString('lastPlayDate');
  Future<void> setLastPlayDate(String date) => _prefs.setString('lastPlayDate', date);

  int getTimeAttackHighScore() => _prefs.getInt('timeAttackHighScore') ?? 0;
  Future<void> setTimeAttackHighScore(int score) => _prefs.setInt('timeAttackHighScore', score);
}
