import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../view_models/game_state.dart';
import 'life_log_list_view.dart';
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
          Expanded(child: _LifeLogPanel(entries: state.stats.lifeLog)),
        ],
      ),
    );
  }
}

class _LifeLogPanel extends StatelessWidget {
  final List<String> entries;

  const _LifeLogPanel({required this.entries});

  @override
  Widget build(BuildContext context) {
    return RetroContainer(
      backgroundColor: const Color(0xFFF4F4F0),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.sectionHeader,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: LifeLogListView(entries: entries),
            ),
          ),
        ],
      ),
    );
  }
}
