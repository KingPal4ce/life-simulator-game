import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nes_ui/nes_ui.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/app_colors.dart';
import 'services/ai_service.dart';
import 'services/local_storage_service.dart';
import 'features/game/view_models/game_state.dart';
import 'features/game/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final localStorageService = LocalStorageService();
  await localStorageService.init();

  final apiKey = dotenv.env['GEMINI_API_KEY'] ??
      const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  if (apiKey.isEmpty) {
    debugPrint('WARNING: GEMINI_API_KEY is not set.');
  }

  final aiService = AIService(apiKey: apiKey);

  runApp(
    ChangeNotifierProvider(
      create: (context) => GameState(
        aiService: aiService,
        localStorageService: localStorageService,
      )..loadOrStartGame(),
      child: const RetroLifeApp(),
    ),
  );
}

class RetroLifeApp extends StatelessWidget {
  const RetroLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retro Life',
      debugShowCheckedModeBanner: false,
      theme: flutterNesTheme().copyWith(
        scaffoldBackgroundColor: AppColors.darkBackground,
      ),
      home: const DashboardScreen(),
    );
  }
}
