import 'package:flutter/foundation.dart';
import '../../../models/models.dart';
import '../../../services/ai_service.dart';
import '../../../services/local_storage_service.dart';
import '../../stats/stats_manager.dart';

class GameState extends ChangeNotifier {
  final AIService aiService;
  final LocalStorageService localStorageService;

  PlayerStats stats = PlayerStats();
  GameEvent? currentEvent;
  bool isGeneratingEvent = false;
  String previousOutcome = 'You were just born.';
  String? currentConsequence;
  EventOption? lastChosenOption;

  // Life story fields
  String? lifeStory;
  bool isGeneratingStory = false;

  bool get isDead => stats.health <= 0 || stats.age >= 100;

  GameState({required this.aiService, required this.localStorageService});

  void loadOrStartGame() {
    final loadedStats = localStorageService.loadStats();

    if (loadedStats != null) {
      stats = loadedStats;
      final savedOutcome = localStorageService.loadPreviousOutcome();
      if (savedOutcome != null) {
        previousOutcome = savedOutcome;
      }

      if (!isDead && currentEvent == null && currentConsequence == null) {
        _triggerNextEvent();
      } else {
        notifyListeners();
      }
    } else {
      startGame();
    }
  }

  void startGame() {
    stats = PlayerStats(lifeLog: ['Age 0: You were born.'], decisions: []);
    previousOutcome = 'You were just born.';
    currentEvent = null;
    currentConsequence = null;
    lifeStory = null;
    isGeneratingStory = false;
    _saveState();
    _triggerNextEvent();
  }

  void addLog(String entry) {
    stats.lifeLog = List.from(stats.lifeLog)..add('Age ${stats.age}: $entry');
    _saveState();
    notifyListeners();
  }

  void _saveState() {
    localStorageService.saveSession(stats, previousOutcome);
  }

  Future<void> _triggerNextEvent() async {
    if (isDead) return;

    isGeneratingEvent = true;
    notifyListeners();

    final recentDecisions = stats.decisions.length > 5
        ? stats.decisions.sublist(stats.decisions.length - 5)
        : stats.decisions;

    currentEvent = await aiService.generateNextEvent(stats, previousOutcome, recentDecisions);

    isGeneratingEvent = false;
    notifyListeners();
  }

  void selectOption(EventOption option) {
    StatsManager.applyOptionEffects(stats, option);

    final outcome = option.outcomeDescription.isNotEmpty
        ? option.outcomeDescription
        : 'You chose to ${option.text}.';

    final decision = Decision(
      age: stats.age,
      eventTitle: currentEvent?.title ?? 'Unknown Event',
      choiceText: option.text,
      outcome: outcome,
    );
    stats.decisions = List.from(stats.decisions)..add(decision);
    lastChosenOption = option;

    addLog('You chose: "${option.text}"');
    if (option.outcomeDescription.isNotEmpty) {
      addLog(option.outcomeDescription);
    }
    currentConsequence = outcome;

    _saveState();
    notifyListeners();
  }

  void continueToNextEvent() {
    previousOutcome = currentConsequence ?? 'You moved on with your life.';
    currentConsequence = null;
    lastChosenOption = null;
    _ageUp();
  }

  void endLife() {
    if (isDead) return;
    stats.health = 0;
    addLog('You chose to end it all at age ${stats.age}.');
    _saveState();
    _triggerLifeStory();
  }

  Future<void> _triggerLifeStory() async {
    isGeneratingStory = true;
    lifeStory = null;
    notifyListeners();

    lifeStory = await aiService.generateLifeStory(stats, stats.lifeLog, stats.decisions);

    isGeneratingStory = false;
    notifyListeners();
  }

  void _ageUp() {
    _checkAchievements();
    if (!isDead) {
      stats.age++;
      _saveState();
      // Re-check after incrementing: reaching age 100 ends the game.
      if (isDead) {
        _triggerLifeStory();
      } else {
        _triggerNextEvent();
      }
    } else {
      _triggerLifeStory();
    }
  }

  void _checkAchievements() {
    if (stats.age >= 80 && !stats.achievements.contains('Centenarian in Training')) {
      stats.achievements = List.from(stats.achievements)..add('Centenarian in Training');
      addLog('Achievement Unlocked: Centenarian in Training!');
    }
    if (stats.happiness == 100 && !stats.achievements.contains('Absolute Bliss')) {
      stats.achievements = List.from(stats.achievements)..add('Absolute Bliss');
      addLog('Achievement Unlocked: Absolute Bliss!');
    }
  }
}
