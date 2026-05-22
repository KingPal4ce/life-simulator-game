import 'package:flutter/foundation.dart';
import '../../../models/models.dart';
import '../../../services/ai_service.dart';
import '../../../services/local_storage_service.dart';
import '../../stats/stats_manager.dart';

class GameState extends ChangeNotifier {
  final IAIService aiService;
  final ILocalStorageService localStorageService;
  final Duration _retryDelay;

  PlayerStats stats = PlayerStats();
  GameEvent? currentEvent;
  bool isGeneratingEvent = false;
  bool eventGenerationFailed = false;
  String previousOutcome = 'You were just born.';
  String? currentConsequence;
  EventOption? lastChosenOption;

  // Life story fields
  String? lifeStory;
  bool isGeneratingStory = false;

  bool get isDead => stats.health <= 0 || stats.age >= 100;

  // Achievement definitions — add new entries here to extend the system.
  static final List<({String name, bool Function(PlayerStats) condition})> _achievementDefs = [
    (name: 'Centenarian in Training', condition: (s) => s.age >= 80),
    (name: 'Absolute Bliss', condition: (s) => s.happiness == 100),
  ];

  GameState({
    required this.aiService,
    required this.localStorageService,
    Duration retryDelay = const Duration(seconds: 1),
  }) : _retryDelay = retryDelay;

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
    if (isDead || isGeneratingEvent) return;

    isGeneratingEvent = true;
    eventGenerationFailed = false;
    notifyListeners();

    final recentDecisions = stats.decisions.length > 5
        ? stats.decisions.sublist(stats.decisions.length - 5)
        : stats.decisions;

    GameEvent? event;
    for (var attempt = 0; attempt < 3; attempt++) {
      event = await aiService.generateNextEvent(stats, previousOutcome, recentDecisions);
      if (event != null) break;
      if (attempt < 2 && _retryDelay.inMicroseconds > 0) await Future.delayed(_retryDelay);
    }

    currentEvent = event;
    if (event == null) eventGenerationFailed = true;
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
    if (isDead) { _triggerLifeStory(); return; }
    stats.age++;
    _saveState();
    if (isDead) { _triggerLifeStory(); } else { _triggerNextEvent(); }
  }

  void _checkAchievements() {
    for (final def in _achievementDefs) {
      if (def.condition(stats) && !stats.achievements.contains(def.name)) {
        stats.achievements = List.from(stats.achievements)..add(def.name);
        addLog('Achievement Unlocked: ${def.name}!');
      }
    }
  }
}
