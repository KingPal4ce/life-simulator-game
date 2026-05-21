import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';
import '../view_models/game_state.dart';
import '../widgets/retro_container.dart';

class DeathScreen extends StatelessWidget {
  final GameState state;

  const DeathScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Center(
            child: Icon(
              Icons.sentiment_very_dissatisfied,
              color: Colors.white,
              size: 64,
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: RetroContainer(
              padding: EdgeInsetsGeometry.all(10),
              backgroundColor: const Color(0xFF1C1F24),
              child: ListView(
                children: [
                  const Text(
                    'LIFE SUMMARY',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _SummaryStat(
                        icon: Icons.calendar_today,
                        label: 'Age',
                        value: '${state.stats.age}',
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'FINAL STATS',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MiniStat(
                        icon: Icons.sentiment_very_satisfied,
                        value: '${state.stats.happiness}',
                        color: Colors.green,
                      ),
                      _MiniStat(
                        icon: Icons.favorite,
                        value: '${state.stats.health}',
                        color: Colors.redAccent,
                      ),
                      _MiniStat(
                        icon: Icons.psychology,
                        value: '${state.stats.smarts}',
                        color: Colors.orange,
                      ),
                      _MiniStat(
                        icon: Icons.face,
                        value: '${state.stats.looks}',
                        color: Colors.purpleAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ACHIEVEMENTS',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (state.stats.achievements.isEmpty)
                    const Text(
                      'None earned this life.',
                      style: TextStyle(color: Colors.white70),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.stats.achievements
                          .map(
                            (a) => Chip(
                              label: Text(
                                a,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.amber.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 32),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text(
                    'YOUR STORY',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (state.isGeneratingStory)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Colors.amber),
                          SizedBox(height: 12),
                          Text(
                            'Writing your life story...',
                            style: TextStyle(
                              color: Colors.white54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (state.lifeStory != null)
                    Text(
                      state.lifeStory!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 2.3,
                      ),
                    )
                  else
                    const Text(
                      'Their story could not be told.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const SizedBox(height: 32),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text(
                    'LIFE LOG',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black45,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: state.stats.lifeLog
                          .map(
                            (log) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                log,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 2.3,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: NesButton(
              type: NesButtonType.primary,
              onPressed: () => state.startGame(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text('Restart Life', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
