import '../../../models/models.dart';

class StatsManager {
  static void applyOptionEffects(PlayerStats stats, EventOption option) {
    stats.happiness = (stats.happiness + option.happinessEffect).clamp(0, 100);
    stats.health = (stats.health + option.healthEffect).clamp(0, 100);
    stats.smarts = (stats.smarts + option.smartsEffect).clamp(0, 100);
    stats.looks = (stats.looks + option.looksEffect).clamp(0, 100);
  }
}
