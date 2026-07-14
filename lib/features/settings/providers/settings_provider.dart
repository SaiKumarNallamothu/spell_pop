import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool isDarkMode;
  final bool isMusicOn;
  final bool isSoundOn;
  final String language;

  SettingsState({
    required this.isDarkMode,
    required this.isMusicOn,
    required this.isSoundOn,
    required this.language,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? isMusicOn,
    bool? isSoundOn,
    String? language,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isMusicOn: isMusicOn ?? this.isMusicOn,
      isSoundOn: isSoundOn ?? this.isSoundOn,
      language: language ?? this.language,
    );
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return SettingsState(
      isDarkMode: prefs.getBool('isDarkMode') ?? false,
      isMusicOn: prefs.getBool('isMusicOn') ?? true,
      isSoundOn: prefs.getBool('isSoundOn') ?? true,
      language: prefs.getString('language') ?? 'en',
    );
  }

  void toggleTheme() {
    final prefs = ref.read(sharedPreferencesProvider);
    final newValue = !state.isDarkMode;
    prefs.setBool('isDarkMode', newValue);
    state = state.copyWith(isDarkMode: newValue);
  }

  void toggleMusic() {
    final prefs = ref.read(sharedPreferencesProvider);
    final newValue = !state.isMusicOn;
    prefs.setBool('isMusicOn', newValue);
    state = state.copyWith(isMusicOn: newValue);
  }

  void toggleSound() {
    final prefs = ref.read(sharedPreferencesProvider);
    final newValue = !state.isSoundOn;
    prefs.setBool('isSoundOn', newValue);
    state = state.copyWith(isSoundOn: newValue);
  }

  void setLanguage(String lang) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString('language', lang);
    state = state.copyWith(language: lang);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
