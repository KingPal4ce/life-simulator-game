import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
const _stages = [
  (label: 'Infant', minAge: 0, maxAge: 4),
  (label: 'Child', minAge: 5, maxAge: 12),
  (label: 'Teen', minAge: 13, maxAge: 19),
  (label: 'Adult', minAge: 20, maxAge: 59),
  (label: 'Senior', minAge: 60, maxAge: 100),
];

class LifeProgressionBar extends StatelessWidget {
  final int age;

  const LifeProgressionBar({super.key, required this.age});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navyBackground,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: _stages.map((stage) {
          final isActive = age >= stage.minAge && age <= stage.maxAge;
          final isPast = age > stage.maxAge;
          return Expanded(child: _StageCell(label: stage.label, isActive: isActive, isPast: isPast));
        }).toList(),
      ),
    );
  }
}

class _StageCell extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isPast;

  const _StageCell({required this.label, required this.isActive, required this.isPast});

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    if (isActive) {
      textColor = AppColors.accentYellow;
    } else if (isPast) {
      textColor = AppColors.textOnDarkMuted;
    } else {
      textColor = Colors.white30;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: isActive
          ? BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            )
          : null,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          color: textColor,
        ),
      ),
    );
  }
}
