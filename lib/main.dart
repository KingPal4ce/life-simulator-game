import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nes_ui/nes_ui.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/ai_service.dart';
import 'services/local_storage_service.dart';
import 'features/game/view_models/game_state.dart';
import 'features/game/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  final aiService = AIService(
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? const String.fromEnvironment('GEMINI_API_KEY', defaultValue: ''),
  );
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameState(aiService: aiService, localStorageService: localStorageService)..loadOrStartGame(),
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
        scaffoldBackgroundColor: const Color(0xFF2E3239), // Dark retro gray
      ),
      home: const DashboardScreen(),
    );
  }
}

