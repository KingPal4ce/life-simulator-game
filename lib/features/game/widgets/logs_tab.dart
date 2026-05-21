import 'package:flutter/material.dart';
import '../view_models/game_state.dart';
import 'retro_container.dart';

class LogsTab extends StatelessWidget {
  final GameState state;

  const LogsTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.stats.achievements.isNotEmpty) ...[
            const Text(
              'ACHIEVEMENTS',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.stats.achievements
                  .map(
                    (a) => Chip(
                      label: Text(
                        a,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.amber.withValues(alpha: 0.8),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(child: _LifeLogPanel(state: state)),
        ],
      ),
    );
  }
}

class _LifeLogPanel extends StatelessWidget {
  final GameState state;

  const _LifeLogPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return RetroContainer(
      backgroundColor: const Color(0xFFF4F4F0),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFF4A6B9C),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              'LIFE LOG',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.stats.lifeLog.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    state.stats.lifeLog[index],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      height: 2.3,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
