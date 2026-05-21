import 'package:flutter/material.dart';
import '../view_models/game_state.dart';
import 'stats_panel.dart';
import 'event_panel.dart';

class LifeTab extends StatelessWidget {
  final GameState state;

  const LifeTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          StatsPanel(stats: state.stats),
          const SizedBox(height: 12),
          Expanded(child: EventPanel(state: state)),
        ],
      ),
    );
  }
}
