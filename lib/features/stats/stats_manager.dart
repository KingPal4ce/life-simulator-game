import '../../../models/models.dart';

class StatsManager {
  static void applyOptionEffects(PlayerStats stats, EventOption option) {
    stats.happiness = (stats.happiness + option.happinessEffect).clamp(0, 100);
    stats.health = (stats.health + option.healthEffect).clamp(0, 100);
    stats.smarts = (stats.smarts + option.smartsEffect).clamp(0, 100);
    stats.looks = (stats.looks + option.looksEffect).clamp(0, 100);
    stats.morality   = (stats.morality   + option.moralityEffect).clamp(0, 100);
    stats.discipline = (stats.discipline + option.disciplineEffect).clamp(0, 100);
    stats.popularity = (stats.popularity + option.popularityEffect).clamp(0, 100);
    stats.creativity = (stats.creativity + option.creativityEffect).clamp(0, 100);
    stats.wealth     = (stats.wealth     + option.wealthEffect).clamp(0, 100);
    stats.greed      = (stats.greed      + option.greedEffect).clamp(0, 100);
    stats.reputation = (stats.reputation + option.reputationEffect).clamp(0, 100);
  }
}
