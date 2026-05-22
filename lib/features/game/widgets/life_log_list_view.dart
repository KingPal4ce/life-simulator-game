import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class LifeLogListView extends StatelessWidget {
  final List<String> entries;
  final TextStyle textStyle;

  const LifeLogListView({
    super.key,
    required this.entries,
    this.textStyle = const TextStyle(
      color: AppColors.logTextOnLight,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      height: 2.3,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(entry, style: textStyle),
            ),
          )
          .toList(),
    );
  }
}
