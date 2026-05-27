import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../models/models.dart';
import '../../../services/ai_service.dart';
import '../../../services/local_storage_service.dart';
import '../../stats/stats_manager.dart';

class GameState extends ChangeNotifier {
  final IAIService aiService;
  final ILocalStorageService localStorageService;
  final Duration _retryDelay;
  final _random = Random();

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

    // Quiet year: ~25% chance for ages 5+ — creates pacing contrast
    if (stats.age >= 5 && _random.nextDouble() < 0.25) {
      final quietText = await aiService.generateQuietYear(stats);
      if (quietText != null) {
        addLog(quietText);
        isGeneratingEvent = false; // reset before re-entering via _ageUp
        _ageUp();
        return;
      }
    }

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
    _updateIdentityState(option);

    if (option.involvedNPC != null && !stats.npcSeeds.contains(option.involvedNPC)) {
      stats.npcSeeds = List.from(stats.npcSeeds)..add(option.involvedNPC!);
    }

    _evaluateLifePath();

    // Tension tracking: resolve before adding so a single option can swap tensions cleanly
    if (option.resolvesTension == true && stats.unresolvedTensions.isNotEmpty) {
      stats.unresolvedTensions = List.from(stats.unresolvedTensions)..removeAt(0);
    }
    if (option.newTension != null) {
      final tensions = List<String>.from(stats.unresolvedTensions)..add(option.newTension!);
      stats.unresolvedTensions = tensions.length > 3 ? tensions.sublist(tensions.length - 3) : tensions;
    }

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

  void _evaluateLifePath() {
    final s = stats;
    String? matched;

    if (s.morality <= 25 && s.greed >= 60) {
      matched = 'Criminal';
    } else if (s.morality >= 85 && s.happiness >= 70 && s.wealth <= 35) {
      matched = 'Spiritual Monk';
    } else if (s.smarts >= 80 && s.popularity <= 30) {
      matched = 'Lonely Genius';
    } else if (s.wealth >= 65 && s.discipline >= 60 && s.greed >= 50) {
      matched = 'Entrepreneur';
    } else if (s.popularity >= 75 && s.looks >= 65) {
      matched = 'Famous Celebrity';
    } else if (s.popularity >= 70 && s.creativity >= 65 && s.age <= 35) {
      matched = 'Internet Influencer';
    } else if (s.morality >= 75 && s.popularity >= 60 && s.greed <= 30) {
      matched = 'Activist / Revolutionary';
    } else if (s.happiness >= 75 && s.morality >= 65 && s.greed <= 40) {
      matched = 'Family Patriarch/Matriarch';
    }

    if (matched != null) {
      stats.lifePath = matched;
    }
  }

  void _updateIdentityState(EventOption chosenOption) {
    final id = stats.identityState;

    if (chosenOption.occupationUpdate != null) {
      id.occupation = chosenOption.occupationUpdate!;
    }
    if (chosenOption.relationshipUpdate != null) {
      id.relationshipStatus = chosenOption.relationshipUpdate!;
    }
    if (chosenOption.criminalRecordUpdate != null) {
      id.criminalRecord = chosenOption.criminalRecordUpdate!;
    }
    if (chosenOption.fameLevelUpdate != null) {
      id.fameLevel = chosenOption.fameLevelUpdate!;
    }
    if (chosenOption.majorEventNote != null) {
      final events = List<String>.from(id.majorPastEvents)
        ..add(chosenOption.majorEventNote!);
      id.majorPastEvents = events.length > 5 ? events.sublist(events.length - 5) : events;
    }

    // Age-based education progression (automatic, no AI signal needed)
    if (stats.age == 18 && id.education == 'no degree') {
      id.education = 'high school';
    }
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
