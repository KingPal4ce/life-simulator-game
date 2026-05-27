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

  group('hidden stat effects', () {
    test('positive effects apply correctly to all 7 hidden stats', () {
      final hiddenStats = PlayerStats(
        morality: 40,
        discipline: 40,
        popularity: 40,
        creativity: 40,
        wealth: 40,
        greed: 40,
        reputation: 40,
      );
      final option = EventOption(
        text: 'Positive hidden',
        moralityEffect: 10,
        disciplineEffect: 10,
        popularityEffect: 10,
        creativityEffect: 10,
        wealthEffect: 10,
        greedEffect: 10,
        reputationEffect: 10,
      );

      StatsManager.applyOptionEffects(hiddenStats, option);

      expect(hiddenStats.morality, 50);
      expect(hiddenStats.discipline, 50);
      expect(hiddenStats.popularity, 50);
      expect(hiddenStats.creativity, 50);
      expect(hiddenStats.wealth, 50);
      expect(hiddenStats.greed, 50);
      expect(hiddenStats.reputation, 50);
    });

    test('negative effects apply correctly to all 7 hidden stats', () {
      final hiddenStats = PlayerStats(
        morality: 60,
        discipline: 60,
        popularity: 60,
        creativity: 60,
        wealth: 60,
        greed: 60,
        reputation: 60,
      );
      final option = EventOption(
        text: 'Negative hidden',
        moralityEffect: -10,
        disciplineEffect: -10,
        popularityEffect: -10,
        creativityEffect: -10,
        wealthEffect: -10,
        greedEffect: -10,
        reputationEffect: -10,
      );

      StatsManager.applyOptionEffects(hiddenStats, option);

      expect(hiddenStats.morality, 50);
      expect(hiddenStats.discipline, 50);
      expect(hiddenStats.popularity, 50);
      expect(hiddenStats.creativity, 50);
      expect(hiddenStats.wealth, 50);
      expect(hiddenStats.greed, 50);
      expect(hiddenStats.reputation, 50);
    });

    test('all 7 hidden stats clamp to 100 maximum', () {
      final hiddenStats = PlayerStats(
        morality: 90,
        discipline: 90,
        popularity: 90,
        creativity: 90,
        wealth: 90,
        greed: 90,
        reputation: 90,
      );
      final option = EventOption(
        text: 'Overflow hidden',
        moralityEffect: 30,
        disciplineEffect: 30,
        popularityEffect: 30,
        creativityEffect: 30,
        wealthEffect: 30,
        greedEffect: 30,
        reputationEffect: 30,
      );

      StatsManager.applyOptionEffects(hiddenStats, option);

      expect(hiddenStats.morality, 100);
      expect(hiddenStats.discipline, 100);
      expect(hiddenStats.popularity, 100);
      expect(hiddenStats.creativity, 100);
      expect(hiddenStats.wealth, 100);
      expect(hiddenStats.greed, 100);
      expect(hiddenStats.reputation, 100);
    });

    test('all 7 hidden stats clamp to 0 minimum', () {
      final hiddenStats = PlayerStats(
        morality: 10,
        discipline: 10,
        popularity: 10,
        creativity: 10,
        wealth: 10,
        greed: 10,
        reputation: 10,
      );
      final option = EventOption(
        text: 'Underflow hidden',
        moralityEffect: -30,
        disciplineEffect: -30,
        popularityEffect: -30,
        creativityEffect: -30,
        wealthEffect: -30,
        greedEffect: -30,
        reputationEffect: -30,
      );

      StatsManager.applyOptionEffects(hiddenStats, option);

      expect(hiddenStats.morality, 0);
      expect(hiddenStats.discipline, 0);
      expect(hiddenStats.popularity, 0);
      expect(hiddenStats.creativity, 0);
      expect(hiddenStats.wealth, 0);
      expect(hiddenStats.greed, 0);
      expect(hiddenStats.reputation, 0);
    });
  });
}
