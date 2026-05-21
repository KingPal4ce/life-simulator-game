import 'package:flutter_test/flutter_test.dart';
import 'package:retro_life_simulator/models/models.dart';

void main() {
  group('Decision', () {
    test('toJson / fromJson round-trip', () {
      final decision = Decision(
        age: 10,
        eventTitle: 'School Test',
        choiceText: 'I study all night',
        outcome: 'You passed with flying colors.',
      );

      final restored = Decision.fromJson(decision.toJson());

      expect(restored.age, 10);
      expect(restored.eventTitle, 'School Test');
      expect(restored.choiceText, 'I study all night');
      expect(restored.outcome, 'You passed with flying colors.');
    });

    test('fromJson uses defaults for missing fields', () {
      final decision = Decision.fromJson({});

      expect(decision.age, 0);
      expect(decision.eventTitle, '');
      expect(decision.choiceText, '');
      expect(decision.outcome, '');
    });

    test('toString includes age and event title', () {
      final decision = Decision(
        age: 5,
        eventTitle: 'Playground',
        choiceText: 'I make a friend',
        outcome: 'You have a new best friend.',
      );

      expect(decision.toString(), contains('Age 5'));
      expect(decision.toString(), contains('Playground'));
    });
  });

  group('PlayerStats', () {
    test('default values', () {
      final stats = PlayerStats();

      expect(stats.age, 0);
      expect(stats.happiness, 80);
      expect(stats.health, 90);
      expect(stats.smarts, 50);
      expect(stats.looks, 50);
      expect(stats.lifeLog, isEmpty);
      expect(stats.achievements, isEmpty);
      expect(stats.decisions, isEmpty);
    });

    test('toJson / fromJson round-trip preserves all fields', () {
      final decision = Decision(age: 3, eventTitle: 'Test', choiceText: 'A', outcome: 'B');
      final stats = PlayerStats(
        age: 25,
        happiness: 70,
        health: 60,
        smarts: 80,
        looks: 55,
        lifeLog: ['Age 0: Born.', 'Age 1: Walked.'],
        achievements: ['First Step'],
        decisions: [decision],
      );

      final restored = PlayerStats.fromJson(stats.toJson());

      expect(restored.age, 25);
      expect(restored.happiness, 70);
      expect(restored.health, 60);
      expect(restored.smarts, 80);
      expect(restored.looks, 55);
      expect(restored.lifeLog, ['Age 0: Born.', 'Age 1: Walked.']);
      expect(restored.achievements, ['First Step']);
      expect(restored.decisions.length, 1);
      expect(restored.decisions.first.eventTitle, 'Test');
    });

    test('fromJson uses defaults for missing fields', () {
      final stats = PlayerStats.fromJson({});

      expect(stats.age, 0);
      expect(stats.happiness, 80);
      expect(stats.health, 90);
      expect(stats.smarts, 50);
      expect(stats.looks, 50);
      expect(stats.lifeLog, isEmpty);
      expect(stats.achievements, isEmpty);
      expect(stats.decisions, isEmpty);
    });

    test('fromJson deserialises nested decisions', () {
      final json = {
        'age': 5,
        'decisions': [
          {'age': 3, 'eventTitle': 'Park', 'choiceText': 'Play', 'outcome': 'Fun.'}
        ],
      };

      final stats = PlayerStats.fromJson(json);

      expect(stats.decisions.length, 1);
      expect(stats.decisions.first.eventTitle, 'Park');
    });
  });

  group('EventOption', () {
    test('fromJson parses all fields', () {
      final option = EventOption.fromJson({
        'text': 'I study hard',
        'outcome_description': 'Your grades improve.',
        'happinessEffect': -5,
        'healthEffect': -10,
        'smartsEffect': 20,
        'looksEffect': 0,
      });

      expect(option.text, 'I study hard');
      expect(option.outcomeDescription, 'Your grades improve.');
      expect(option.happinessEffect, -5);
      expect(option.healthEffect, -10);
      expect(option.smartsEffect, 20);
      expect(option.looksEffect, 0);
    });

    test('fromJson defaults all effects to 0 when absent', () {
      final option = EventOption.fromJson({'text': 'Do nothing'});

      expect(option.happinessEffect, 0);
      expect(option.healthEffect, 0);
      expect(option.smartsEffect, 0);
      expect(option.looksEffect, 0);
    });

    test('default constructor sets empty outcomeDescription', () {
      final option = EventOption(text: 'Just exist');

      expect(option.outcomeDescription, '');
    });
  });

  group('GameEvent', () {
    test('fromJson parses title, description, and options', () {
      final event = GameEvent.fromJson({
        'title': 'First Day of School',
        'description': 'You walk into class.',
        'options': [
          {
            'text': 'I sit in the front',
            'outcome_description': 'Teacher notices you.',
            'happinessEffect': 5,
            'healthEffect': 0,
            'smartsEffect': 10,
            'looksEffect': 0,
          },
        ],
      });

      expect(event.title, 'First Day of School');
      expect(event.description, 'You walk into class.');
      expect(event.options.length, 1);
      expect(event.options.first.text, 'I sit in the front');
      expect(event.options.first.smartsEffect, 10);
    });

    test('fromJson handles multiple options', () {
      final event = GameEvent.fromJson({
        'title': 'Crossroads',
        'description': 'A choice awaits.',
        'options': [
          {'text': 'A', 'outcome_description': '', 'happinessEffect': 0, 'healthEffect': 0, 'smartsEffect': 0, 'looksEffect': 0},
          {'text': 'B', 'outcome_description': '', 'happinessEffect': 0, 'healthEffect': 0, 'smartsEffect': 0, 'looksEffect': 0},
          {'text': 'C', 'outcome_description': '', 'happinessEffect': 0, 'healthEffect': 0, 'smartsEffect': 0, 'looksEffect': 0},
        ],
      });

      expect(event.options.length, 3);
    });
  });
}
