import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/router/router.dart';
import 'app/theme/theme.dart';
import 'features/settings/providers/settings_provider.dart';
import 'core/services/database_service.dart';
import 'core/services/ad_service.dart';
import 'core/providers/services_provider.dart';

void main() async {
  // Ensure widget binding is initialized before SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // Load offline word database
  final dbService = DatabaseService(prefs);
  await dbService.init();

  // Initialize Google Mobile Ads
  final adService = AdService();
  await adService.init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseServiceProvider.overrideWithValue(dbService),
        adServiceProvider.overrideWithValue(adService),
      ],
      child: const SpellPopApp(),
    ),
  );
}

class SpellPopApp extends ConsumerWidget {
  const SpellPopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch settings state to dynamically switch theme mode
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'SpellPop',
      debugShowCheckedModeBanner: false,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
