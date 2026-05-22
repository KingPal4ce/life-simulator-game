// FakeAIService methods return immediately (no real async delay).
// Future.delayed(Duration.zero) flushes the microtask queue to let
// _triggerNextEvent / _triggerLifeStory complete. If a fake is ever
// changed to simulate real delays, replace with proper await chains or Completer.
import 'package:flutter_test/flutter_test.dart';
import 'package:retro_life_simulator/features/game/view_models/game_state.dart';
import 'package:retro_life_simulator/models/models.dart';
import 'package:retro_life_simulator/services/ai_service.dart';
import 'package:retro_life_simulator/services/local_storage_service.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeLocalStorageService implements ILocalStorageService {
  PlayerStats? _stats;
  String? _outcome;

  @override
  Future<void> init() async {}

  @override
  void saveSession(PlayerStats stats, String previousOutcome) {
    _stats = stats;
    _outcome = previousOutcome;
  }

  @override
  PlayerStats? loadStats() => _stats;

  @override
  String? loadPreviousOutcome() => _outcome;

  @override
  void clearSession() {
    _stats = null;
    _outcome = null;
  }
}

class FakeAIService implements IAIService {
  int generateEventCallCount = 0;
  int generateStoryCallCount = 0;

  /// Return null for the first N calls to generateNextEvent.
  int failFirstNCalls = 0;

  @override
  Future<GameEvent?> generateNextEvent(
    PlayerStats stats,
    String previousOutcome,
    List<Decision> recentDecisions,
  ) async {
    generateEventCallCount++;
    if (generateEventCallCount <= failFirstNCalls) return null;
    return GameEvent(
      title: 'Test Event',
      description: 'A test event happens.',
      options: [
        EventOption(
          text: 'I take the safe path',
          outcomeDescription: 'You proceed calmly.',
          happinessEffect: 5,
          smartsEffect: 5,
        ),
        EventOption(
          text: 'I take the risky path',
          outcomeDescription: 'You gamble and win.',
          happinessEffect: 15,
          healthEffect: -10,
          looksEffect: 5,
        ),
      ],
    );
  }

  @override
  Future<String> generateLifeStory(
    PlayerStats stats,
    List<String> lifeLog,
    List<Decision> decisions,
  ) async {
    generateStoryCallCount++;
    return 'A life well lived.';
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

GameEvent _makeEvent({String title = 'Career Choice'}) => GameEvent(
      title: title,
      description: 'What do you do?',
      options: [],
    );

EventOption _makeOption({
  String text = 'I choose',
  String outcome = 'Something happens.',
  int happiness = 0,
  int health = 0,
  int smarts = 0,
  int looks = 0,
}) =>
    EventOption(
      text: text,
      outcomeDescription: outcome,
      happinessEffect: happiness,
      healthEffect: health,
      smartsEffect: smarts,
      looksEffect: looks,
    );

GameState _makeState({
  FakeAIService? ai,
  FakeLocalStorageService? lss,
}) {
  return GameState(
    aiService: ai ?? FakeAIService(),
    localStorageService: lss ?? FakeLocalStorageService(),
    retryDelay: Duration.zero,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeAIService fakeAI;
  late FakeLocalStorageService fakeLSS;
  late GameState state;

  setUp(() {
    fakeAI = FakeAIService();
    fakeLSS = FakeLocalStorageService();
    state = _makeState(ai: fakeAI, lss: fakeLSS);
  });

  // -------------------------------------------------------------------------
  group('isDead', () {
    test('false for a healthy player under age 100', () {
      state.stats = PlayerStats(age: 50, health: 50);
      expect(state.isDead, isFalse);
    });

    test('true when health reaches 0', () {
      state.stats = PlayerStats(age: 30, health: 0);
      expect(state.isDead, isTrue);
    });

    test('true when age reaches 100', () {
      state.stats = PlayerStats(age: 100, health: 80);
      expect(state.isDead, isTrue);
    });

    test('true when both health is 0 and age is 100', () {
      state.stats = PlayerStats(age: 100, health: 0);
      expect(state.isDead, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  group('startGame', () {
    test('resets stats to starting values', () {
      state.startGame();

      expect(state.stats.age, 0);
      expect(state.stats.happiness, 80);
      expect(state.stats.health, 90);
      expect(state.stats.smarts, 50);
      expect(state.stats.looks, 50);
    });

    test('seeds lifeLog with birth entry', () {
      state.startGame();

      expect(state.stats.lifeLog, contains('Age 0: You were born.'));
    });

    test('resets previousOutcome to birth message', () {
      state.previousOutcome = 'old outcome';
      state.startGame();

      expect(state.previousOutcome, 'You were just born.');
    });

    test('clears currentConsequence and lifeStory', () {
      state.currentConsequence = 'old consequence';
      state.lifeStory = 'old story';

      state.startGame();

      expect(state.currentConsequence, isNull);
      expect(state.lifeStory, isNull);
    });

    test('saves initial session to storage', () {
      state.startGame();

      expect(fakeLSS.loadStats(), isNotNull);
    });

    test('triggers event generation', () async {
      state.startGame();
      await Future.delayed(Duration.zero);

      expect(fakeAI.generateEventCallCount, greaterThanOrEqualTo(1));
    });

    test('sets currentEvent after generation completes', () async {
      state.startGame();
      await Future.delayed(Duration.zero);

      expect(state.currentEvent, isNotNull);
      expect(state.currentEvent!.title, 'Test Event');
    });
  });

  // -------------------------------------------------------------------------
  group('loadOrStartGame', () {
    test('starts a fresh game when no saved session exists', () {
      state.loadOrStartGame();

      expect(state.stats.age, 0);
    });

    test('restores saved stats when a session exists', () async {
      final saved = PlayerStats(age: 15, happiness: 70, health: 60, smarts: 65, looks: 55);
      fakeLSS.saveSession(saved, 'You had a good day.');

      state.loadOrStartGame();
      await Future.delayed(Duration.zero);

      expect(state.stats.age, 15);
      expect(state.stats.happiness, 70);
    });

    test('restores previousOutcome from saved session', () async {
      final saved = PlayerStats(age: 10);
      fakeLSS.saveSession(saved, 'You won a trophy.');

      state.loadOrStartGame();
      await Future.delayed(Duration.zero);

      expect(state.previousOutcome, 'You won a trophy.');
    });
  });

  // -------------------------------------------------------------------------
  group('addLog', () {
    test('appends entry prefixed with current age', () {
      state.startGame();
      state.stats.age = 5;

      state.addLog('You learned to ride a bike.');

      expect(state.stats.lifeLog.last, 'Age 5: You learned to ride a bike.');
    });

    test('persists updated log to storage', () {
      state.startGame();
      state.addLog('A notable moment.');

      final saved = fakeLSS.loadStats();
      expect(saved?.lifeLog, anyElement(contains('A notable moment.')));
    });

    test('notifies listeners', () {
      state.startGame();
      var notified = false;
      state.addListener(() => notified = true);

      state.addLog('Something happened.');

      expect(notified, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  group('selectOption', () {
    setUp(() async {
      state.startGame();
      await Future.delayed(Duration.zero); // let _triggerNextEvent settle
      state.currentEvent = _makeEvent();   // override with predictable event
    });

    test('applies stat effects', () {
      final initialSmarts = state.stats.smarts;
      final option = _makeOption(smarts: 20, happiness: -5);

      state.selectOption(option);

      expect(state.stats.smarts, initialSmarts + 20);
      expect(state.stats.happiness, 80 - 5); // default happiness is 80
    });

    test('records a Decision with correct fields', () {
      final option = _makeOption(text: 'I take a gap year', outcome: 'You travel the world.');

      state.selectOption(option);

      final decision = state.stats.decisions.last;
      expect(decision.choiceText, 'I take a gap year');
      expect(decision.outcome, 'You travel the world.');
      expect(decision.eventTitle, 'Career Choice');
      expect(decision.age, state.stats.age);
    });

    test('sets currentConsequence to outcomeDescription when provided', () {
      final option = _makeOption(text: 'Something', outcome: 'A vivid outcome.');

      state.selectOption(option);

      expect(state.currentConsequence, 'A vivid outcome.');
    });

    test('falls back to "You chose to <text>." when outcomeDescription is empty', () {
      final option = EventOption(text: 'I just exist');

      state.selectOption(option);

      expect(state.currentConsequence, 'You chose to I just exist.');
    });

    test('sets lastChosenOption', () {
      final option = _makeOption(text: 'My choice');

      state.selectOption(option);

      expect(state.lastChosenOption, same(option));
    });

    test('adds a log entry containing the chosen text', () {
      final logsBefore = state.stats.lifeLog.length;
      final option = _makeOption(text: 'I go hiking', outcome: '');

      state.selectOption(option);

      expect(state.stats.lifeLog.length, greaterThan(logsBefore));
      expect(state.stats.lifeLog, anyElement(contains('I go hiking')));
    });

    test('adds outcome log entry when outcomeDescription is non-empty', () {
      final option = _makeOption(text: 'Something', outcome: 'Epic consequence.');

      state.selectOption(option);

      expect(state.stats.lifeLog, anyElement(contains('Epic consequence.')));
    });

    test('notifies listeners', () {
      var notified = false;
      state.addListener(() => notified = true);

      state.selectOption(_makeOption());

      expect(notified, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  group('continueToNextEvent', () {
    setUp(() async {
      state.startGame();
      await Future.delayed(Duration.zero); // let initial event generation settle
    });

    test('sets previousOutcome from currentConsequence', () {
      state.currentConsequence = 'You climbed a mountain.';

      state.continueToNextEvent();

      expect(state.previousOutcome, 'You climbed a mountain.');
    });

    test('uses fallback when currentConsequence is null', () {
      state.currentConsequence = null;

      state.continueToNextEvent();

      expect(state.previousOutcome, 'You moved on with your life.');
    });

    test('clears currentConsequence and lastChosenOption', () {
      state.currentConsequence = 'Some outcome.';
      state.lastChosenOption = EventOption(text: 'old choice');

      state.continueToNextEvent();

      expect(state.currentConsequence, isNull);
      expect(state.lastChosenOption, isNull);
    });

    test('increments age when player is alive', () {
      state.stats.age = 10;
      state.stats.health = 80;

      state.continueToNextEvent();

      expect(state.stats.age, 11);
    });

    test('triggers next event generation when alive', () async {
      final callsBefore = fakeAI.generateEventCallCount;
      state.stats.health = 80;

      state.continueToNextEvent();
      await Future.delayed(Duration.zero);

      expect(fakeAI.generateEventCallCount, greaterThan(callsBefore));
    });

    test('triggers life story when player dies of old age', () async {
      state.stats.age = 99;
      state.stats.health = 1;

      state.continueToNextEvent(); // age → 100, isDead == true
      await Future.delayed(Duration.zero);

      expect(fakeAI.generateStoryCallCount, greaterThanOrEqualTo(1));
    });
  });

  // -------------------------------------------------------------------------
  group('endLife', () {
    setUp(() {
      state.startGame();
    });

    test('sets health to 0', () {
      state.stats.health = 80;

      state.endLife();

      expect(state.stats.health, 0);
    });

    test('does nothing if already dead', () async {
      state.stats.health = 0;
      final callsBefore = fakeAI.generateStoryCallCount;

      state.endLife();

      expect(fakeAI.generateStoryCallCount, callsBefore);
    });

    test('adds a log entry referencing the player age', () {
      state.stats.age = 42;
      state.stats.health = 80;

      state.endLife();

      expect(state.stats.lifeLog, anyElement(contains('end it all')));
    });

    test('triggers life story generation', () async {
      state.stats.health = 80;

      state.endLife();
      await Future.delayed(Duration.zero);

      expect(fakeAI.generateStoryCallCount, greaterThanOrEqualTo(1));
    });

    test('sets lifeStory after generation completes', () async {
      state.stats.health = 80;

      state.endLife();
      await Future.delayed(Duration.zero);

      expect(state.lifeStory, 'A life well lived.');
    });

    test('sets isGeneratingStory to false after completion', () async {
      state.stats.health = 80;

      state.endLife();
      await Future.delayed(Duration.zero);

      expect(state.isGeneratingStory, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('achievement unlocking', () {
    setUp(() async {
      state.startGame();
      await Future.delayed(Duration.zero);
    });

    test('unlocks Centenarian in Training at age 80', () {
      state.stats.age = 80;
      state.stats.health = 50;

      state.continueToNextEvent();

      expect(state.stats.achievements, contains('Centenarian in Training'));
    });

    test('does not duplicate Centenarian in Training', () {
      state.stats.age = 80;
      state.stats.health = 50;
      state.stats.achievements = ['Centenarian in Training'];

      state.continueToNextEvent();

      final count = state.stats.achievements
          .where((a) => a == 'Centenarian in Training')
          .length;
      expect(count, 1);
    });

    test('unlocks Absolute Bliss at happiness 100', () {
      state.stats.age = 20;
      state.stats.health = 80;
      state.stats.happiness = 100;

      state.continueToNextEvent();

      expect(state.stats.achievements, contains('Absolute Bliss'));
    });

    test('does not duplicate Absolute Bliss', () {
      state.stats.age = 20;
      state.stats.health = 80;
      state.stats.happiness = 100;
      state.stats.achievements = ['Absolute Bliss'];

      state.continueToNextEvent();

      final count = state.stats.achievements
          .where((a) => a == 'Absolute Bliss')
          .length;
      expect(count, 1);
    });

    test('does not unlock Centenarian before age 80', () {
      state.stats.age = 79;
      state.stats.health = 80;

      state.continueToNextEvent();

      expect(state.stats.achievements, isNot(contains('Centenarian in Training')));
    });
  });

  // -------------------------------------------------------------------------
  group('isGeneratingEvent flag', () {
    test('is true immediately after continueToNextEvent and false once done', () async {
      state.startGame();
      await Future.delayed(Duration.zero);
      state.stats.age = 20;
      state.stats.health = 80;

      state.continueToNextEvent();
      expect(state.isGeneratingEvent, isTrue);

      await Future.delayed(Duration.zero);
      expect(state.isGeneratingEvent, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('eventGenerationFailed (H2)', () {
    test('is false initially', () {
      expect(state.eventGenerationFailed, isFalse);
    });

    test('is set to true when all retry attempts return null', () async {
      fakeAI.failFirstNCalls = 999; // always fail
      state.startGame();
      await Future.delayed(Duration.zero);

      expect(state.eventGenerationFailed, isTrue);
      expect(state.currentEvent, isNull);
    });

    test('is false after a successful generation', () async {
      state.startGame();
      await Future.delayed(Duration.zero);

      expect(state.eventGenerationFailed, isFalse);
    });

    test('resets to false at the start of each new generation attempt', () async {
      fakeAI.failFirstNCalls = 999;
      state.startGame();
      await Future.delayed(Duration.zero);
      expect(state.eventGenerationFailed, isTrue);

      // Reset the fake to succeed, then trigger a fresh start
      fakeAI.failFirstNCalls = 0;
      state.startGame();
      await Future.delayed(Duration.zero);

      expect(state.eventGenerationFailed, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('retry logic (H3)', () {
    test('succeeds after two failures — callCount is 3, event is non-null', () async {
      fakeAI.failFirstNCalls = 2; // fail first 2, succeed on 3rd
      state.startGame();
      await Future.delayed(Duration.zero);

      expect(fakeAI.generateEventCallCount, 3);
      expect(state.currentEvent, isNotNull);
      expect(state.eventGenerationFailed, isFalse);
    });

    test('sets eventGenerationFailed when all 3 attempts fail', () async {
      fakeAI.failFirstNCalls = 999; // always fail
      state.startGame();
      await Future.delayed(Duration.zero);

      expect(fakeAI.generateEventCallCount, 3);
      expect(state.eventGenerationFailed, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  group('duplicate in-flight guard (H4)', () {
    test('second generation attempt while one is in-progress is dropped', () async {
      // startGame fires _triggerNextEvent once; isGeneratingEvent becomes true sync.
      // Calling startGame again immediately re-enters _triggerNextEvent which returns early.
      state.startGame();
      state.startGame(); // second call: _triggerNextEvent guard fires

      await Future.delayed(Duration.zero);

      // Only 1 actual AI call despite 2 start attempts
      expect(fakeAI.generateEventCallCount, 1);
    });
  });
}
