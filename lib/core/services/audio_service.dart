import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  final SharedPreferences _prefs;

  AudioService(this._prefs);

  bool get _soundEffectsEnabled => _prefs.getBool('sound_effects') ?? true;
  bool get _musicEnabled => _prefs.getBool('music') ?? true;

  Future<void> playClickSound() async {
    if (!_soundEffectsEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  Future<void> playCorrectSound() async {
    if (!_soundEffectsEnabled) return;
    try {
      // SystemSound doesn't have a correct sound, but we can play click twice or log it
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  Future<void> playWrongSound() async {
    if (!_soundEffectsEnabled) return;
    try {
      // SystemSound has alert/beep on some platforms
      await HapticFeedback.vibrate();
    } catch (_) {}
  }

  void startBackgroundMusic() {
    if (!_musicEnabled) return;
    // Log/Manage loop placeholders
  }

  void stopBackgroundMusic() {
    // Stop background music
  }
}
