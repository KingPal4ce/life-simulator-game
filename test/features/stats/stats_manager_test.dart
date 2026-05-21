import 'package:flutter_test/flutter_test.dart';
import 'package:retro_life_simulator/features/stats/stats_manager.dart';
import 'package:retro_life_simulator/models/models.dart';

void main() {
  group('StatsManager.applyOptionEffects', () {
    late PlayerStats stats;

    setUp(() {
      stats = PlayerStats(happiness: 50, health: 50, smarts: 50, looks: 50);
    });

    test('applies positive effects to all stats', () {
      final option = EventOption(
        text: 'Exercise',
        happinessEffect: 10,
        healthEffect: 20,
        smartsEffect: 5,
        looksEffect: 15,
      );

      StatsManager.applyOptionEffects(stats, option);

      expect(stats.happiness, 60);
      expect(stats.health, 70);
      expect(stats.smarts, 55);
      expect(stats.looks, 65);
    });

    test('applies negative effects to all stats', () {
      final option = EventOption(
        text: 'Skip sleep',
        happinessEffect: -10,
        healthEffect: -20,
        smartsEffect: -5,
        looksEffect: -15,
      );

      StatsManager.applyOptionEffects(stats, option);

      expect(stats.happiness, 40);
      expect(stats.health, 30);
      expect(stats.smarts, 45);
      expect(stats.looks, 35);
    });

    test('clamps all stats to 100 maximum', () {
      stats = PlayerStats(happiness: 90, health: 95, smarts: 80, looks: 85);
      final option = EventOption(
        text: 'Perfect day',
        happinessEffect: 30,
        healthEffect: 30,
        smartsEffect: 30,
        looksEffect: 30,
      );

      StatsManager.applyOptionEffects(stats, option);

      expect(stats.happiness, 100);
      expect(stats.health, 100);
      expect(stats.smarts, 100);
      expect(stats.looks, 100);
    });

    test('clamps all stats to 0 minimum', () {
      stats = PlayerStats(happiness: 10, health: 5, smarts: 20, looks: 15);
      final option = EventOption(
        text: 'Terrible accident',
        happinessEffect: -30,
        healthEffect: -30,
        smartsEffect: -30,
        looksEffect: -30,
      );

      StatsManager.applyOptionEffects(stats, option);

      expect(stats.happiness, 0);
      expect(stats.health, 0);
      expect(stats.smarts, 0);
      expect(stats.looks, 0);
    });

    test('zero effects leave all stats unchanged', () {
      final option = EventOption(text: 'Nothing happens');

      StatsManager.applyOptionEffects(stats, option);

      expect(stats.happiness, 50);
      expect(stats.health, 50);
      expect(stats.smarts, 50);
      expect(stats.looks, 50);
    });

    test('affects only the stat with a non-zero effect', () {
      final option = EventOption(text: 'Read a book', smartsEffect: 15);

      StatsManager.applyOptionEffects(stats, option);

      expect(stats.happiness, 50);
      expect(stats.health, 50);
      expect(stats.smarts, 65);
      expect(stats.looks, 50);
    });

    test('clamp is applied per-stat independently', () {
      stats = PlayerStats(happiness: 95, health: 5, smarts: 50, looks: 50);
      final option = EventOption(
        text: 'Mixed day',
        happinessEffect: 30,
        healthEffect: -30,
        smartsEffect: 5,
        looksEffect: -5,
      );

      StatsManager.applyOptionEffects(stats, option);

      expect(stats.happiness, 100); // 95 + 30 → clamped to 100
      expect(stats.health, 0);      // 5 - 30 → clamped to 0
      expect(stats.smarts, 55);
      expect(stats.looks, 45);
    });
  });
}
