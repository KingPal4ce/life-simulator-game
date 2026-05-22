import 'package:flutter/material.dart';
import 'retro_container.dart';

class RetroStatBar extends StatelessWidget {
  final String label;
  final int value; // 0 to 100
  final IconData icon;
  final Color barColor;

  const RetroStatBar({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.barColor = const Color(0xFF71C558), // Retro green
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Pixelated Icon
          Icon(icon, color: Colors.orangeAccent),
          const SizedBox(width: 8),

          // Label
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),

          // The Progress Bar
          Expanded(
            child: RetroContainer(
              padding: EdgeInsets.zero,
              child: Stack(
                children: [
                  // Background track
                  Container(height: 16, color: Colors.grey[300]),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: (value / 100.0).clamp(0.0, 1.0),
                    child: Container(height: 16, color: barColor),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),
          // Value text
          SizedBox(
            width: 45,
            child: Text(
              value.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
