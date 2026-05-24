import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../models/models.dart';
import 'modern_card.dart';
import 'stat_bar.dart';

class StatsPanel extends StatelessWidget {
  final PlayerStats stats;

  const StatsPanel({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ModernCardHeader(
            label: '⭐  STATS',
            startColor: AppColors.statsHeaderStart,
            endColor: AppColors.statsHeaderEnd,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ModernStatBar(label: 'Happiness', value: stats.happiness, emoji: '😊'),
                ModernStatBar(label: 'Health', value: stats.health, emoji: '❤️'),
                ModernStatBar(label: 'Smarts', value: stats.smarts, emoji: '🧠'),
                ModernStatBar(label: 'Looks', value: stats.looks, emoji: '👕'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
