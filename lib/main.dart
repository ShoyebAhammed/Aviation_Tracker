import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/flight_local_datasource.dart';
import 'data/datasources/flight_remote_datasource.dart';
import 'data/repositories/flight_repository.dart';
import 'presentation/providers/flight_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Persistence & Hive Caching
  final localDataSource = FlightLocalDataSource();
  await localDataSource.init();

  final remoteDataSource = FlightRemoteDataSource();
  final flightRepository = FlightRepository(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<FlightProvider>(
          create: (_) => FlightProvider(
            repository: flightRepository,
            settingsProvider: settingsProvider,
          ),
        ),
      ],
      child: const SkyTrackApp(),
    ),
  );
}

class SkyTrackApp extends StatelessWidget {
  const SkyTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'SkyTrack Pro - Aviation Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}
