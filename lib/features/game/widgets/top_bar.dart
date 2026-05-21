import 'package:flutter/material.dart';
import '../view_models/game_state.dart';

class TopBar extends StatelessWidget {
  final GameState state;

  const TopBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C1F24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.child_care, color: Colors.amber, size: 32),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RetroLife', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Life Simulator', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _TopBadge(icon: Icons.calendar_today, label: 'Age', value: '${state.stats.age}'),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.dangerous, color: Colors.redAccent),
                onPressed: () => _showSurrenderDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSurrenderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2E3239),
        title: const Text('End Life?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to surrender?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              state.endLife();
            },
            child: const Text('Yes, end it', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _TopBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TopBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 4),
        Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
