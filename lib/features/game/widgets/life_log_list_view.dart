import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

String lifeStageForAge(int age) {
  if (age <= 4) return 'Infant';
  if (age <= 12) return 'Child';
  if (age <= 19) return 'Teen';
  if (age <= 59) return 'Adult';
  return 'Senior';
}

class LifeLogListView extends StatelessWidget {
  final List<String> entries;
  final int? maxEntries;
  final bool isDarkMode;

  const LifeLogListView({
    super.key,
    required this.entries,
    this.maxEntries,
    this.isDarkMode = false,
  });

  int? _parseAge(String entry) {
    final match = RegExp(r'^Age\s+(\d+)').firstMatch(entry);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? AppColors.textOnDarkMuted : AppColors.textPrimary;
    final stageColor = isDarkMode ? AppColors.textOnDark : AppColors.selectedChoice;
    final dividerColor = isDarkMode ? Colors.white12 : Colors.grey.shade200;

    final displayed = maxEntries != null && entries.length > maxEntries!
        ? entries.sublist(entries.length - maxEntries!)
        : entries;

    final items = <Widget>[];
    String? lastStage;

    for (final entry in displayed) {
      final age = _parseAge(entry);
      final stage = age != null ? lifeStageForAge(age) : null;

      if (stage != null && stage != lastStage) {
        if (items.isNotEmpty) {
          items.add(Divider(color: dividerColor, height: 16));
        }
        items.add(_StageHeaderRow(label: stage, color: stageColor));
        lastStage = stage;
      }

      final entryText = entry.contains(':') ? entry.split(':').skip(1).join(':').trim() : entry;
      final ageLabel = age != null ? 'Age $age' : null;

      items.add(_LogEntryRow(
        ageLabel: ageLabel,
        text: entryText,
        textColor: textColor,
        accentColor: stageColor,
      ));
    }

    if (items.isEmpty) {
      return Text(
        'No entries yet.',
        style: TextStyle(color: textColor, fontSize: 12),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items,
    );
  }
}

class _StageHeaderRow extends StatelessWidget {
  final String label;
  final Color color;

  const _StageHeaderRow({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _LogEntryRow extends StatelessWidget {
  final String? ageLabel;
  final String text;
  final Color textColor;
  final Color accentColor;

  const _LogEntryRow({
    required this.ageLabel,
    required this.text,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ageLabel != null) ...[
            Text(
              ageLabel!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
