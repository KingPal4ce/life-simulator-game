import 'package:flutter/material.dart';
import '../../../models/models.dart';
import 'retro_container.dart';
import 'stat_bar.dart';

class StatsPanel extends StatelessWidget {
  final PlayerStats stats;

  const StatsPanel({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return RetroContainer(
      backgroundColor: const Color(0xFFF4F4F0),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF4A6B9C),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              'STATS',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                RetroStatBar(label: 'Happiness', value: stats.happiness, icon: Icons.sentiment_very_satisfied, barColor: Colors.green),
                RetroStatBar(label: 'Health', value: stats.health, icon: Icons.favorite, barColor: Colors.green),
                RetroStatBar(label: 'Smarts', value: stats.smarts, icon: Icons.psychology, barColor: Colors.orange),
                RetroStatBar(label: 'Looks', value: stats.looks, icon: Icons.face, barColor: Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
