import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../view_models/game_state.dart';
import '../widgets/life_log_list_view.dart';
import '../widgets/modern_card.dart';

class DeathScreen extends StatelessWidget {
  final GameState state;

  const DeathScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.deathBackground,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Center(child: Text('😢', style: TextStyle(fontSize: 64))),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'GAME OVER',
              style: TextStyle(
                color: AppColors.accentYellow,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Your life has ended',
              style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ModernCard(
              backgroundColor: const Color(0xFF1E2D4A),
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const Text(
                    'LIFE SUMMARY',
                    style: TextStyle(
                      color: AppColors.accentYellow,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
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
                        color: AppColors.accentYellow,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'FINAL STATS',
                    style: TextStyle(
                      color: AppColors.textOnDarkMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MiniStat(emoji: '😊', value: '${state.stats.happiness}'),
                      _MiniStat(emoji: '❤️', value: '${state.stats.health}'),
                      _MiniStat(emoji: '🧠', value: '${state.stats.smarts}'),
                      _MiniStat(emoji: '👕', value: '${state.stats.looks}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ACHIEVEMENTS',
                    style: TextStyle(
                      color: AppColors.textOnDarkMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (state.stats.achievements.isEmpty)
                    const Text(
                      'None earned this life.',
                      style: TextStyle(color: AppColors.textOnDarkMuted),
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
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: AppColors.accentYellow.withValues(alpha: 0.9),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),
                  const Text(
                    'YOUR STORY',
                    style: TextStyle(
                      color: AppColors.accentYellow,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (state.isGeneratingStory)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: AppColors.accentYellow),
                          SizedBox(height: 12),
                          Text(
                            'Writing your life story...',
                            style: TextStyle(
                              color: AppColors.textOnDarkMuted,
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
                        color: AppColors.textOnDark,
                        fontSize: 15,
                        height: 1.8,
                      ),
                    )
                  else
                    const Text(
                      'Their story could not be told.',
                      style: TextStyle(
                        color: AppColors.textOnDarkMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),
                  const Text(
                    'LIFE LOG',
                    style: TextStyle(
                      color: AppColors.textOnDarkMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LifeLogListView(
                    entries: state.stats.lifeLog,
                    isDarkMode: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentYellow,
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              onPressed: () => state.startGame(),
              child: const Text('Start New Life'),
            ),
          ),
          const SizedBox(height: 20),
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
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 12)),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String emoji;
  final String value;

  const _MiniStat({required this.emoji, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
