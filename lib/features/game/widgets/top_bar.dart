import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../view_models/game_state.dart';
import 'life_log_list_view.dart' show lifeStageForAge;

class TopBar extends StatelessWidget {
  final GameState state;

  const TopBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navyBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: const Center(
              child: Text('👤', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'LifeSimulator',
                style: TextStyle(
                  color: AppColors.accentYellow,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                lifeStageForAge(state.stats.age),
                style: const TextStyle(
                  color: AppColors.textOnDarkMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          _AgePill(age: state.stats.age),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showSurrenderDialog(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSurrenderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyBackground,
        title: const Text('End Life?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to surrender?',
          style: TextStyle(color: AppColors.textOnDarkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textOnDarkMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              state.endLife();
            },
            child: const Text(
              'Yes, end it',
              style: TextStyle(color: AppColors.deltaNegative),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgePill extends StatelessWidget {
  final int age;

  const _AgePill({required this.age});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            'Age $age',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
