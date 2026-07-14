import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../services/database_service.dart';
import '../services/ad_service.dart';
import '../services/audio_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DatabaseService(prefs);
});

final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AudioService(prefs);
});
