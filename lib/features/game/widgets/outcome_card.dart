import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../models/models.dart';
import 'modern_card.dart';

class OutcomeCard extends StatelessWidget {
  final String? consequence;
  final EventOption? lastChosenOption;
  final VoidCallback onContinue;

  const OutcomeCard({
    super.key,
    required this.consequence,
    required this.lastChosenOption,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ModernCardHeader(
            label: '🏆  OUTCOME',
            startColor: AppColors.outcomeHeaderStart,
            endColor: AppColors.outcomeHeaderEnd,
          ),
          Expanded(
            child: consequence == null
                ? _buildPlaceholder()
                : _buildConsequence(consequence!, lastChosenOption),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🏆', style: TextStyle(fontSize: 32)),
          SizedBox(height: 8),
          Text(
            'Make a choice to see your outcome',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsequence(String text, EventOption? opt) {
    final deltas = _buildDeltas(opt);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          if (deltas.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFE5E7EB)),
            const SizedBox(height: 8),
            const Text(
              'Effects on your stats:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: deltas),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.selectedChoice,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: onContinue,
            child: const Text('Next Year →'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDeltas(EventOption? opt) {
    if (opt == null) return [];
    final results = <Widget>[];
    void add(String emoji, String label, int val) {
      if (val == 0) return;
      results.add(_DeltaChip(emoji: emoji, label: label, value: val));
    }

    add('😊', 'Happiness', opt.happinessEffect);
    add('❤️', 'Health', opt.healthEffect);
    add('🧠', 'Smarts', opt.smartsEffect);
    add('👕', 'Looks', opt.looksEffect);
    return results;
  }
}

class _DeltaChip extends StatelessWidget {
  final String emoji;
  final String label;
  final int value;

  const _DeltaChip({required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isPositive = value > 0;
    final sign = isPositive ? '+' : '';
    final color = isPositive ? AppColors.deltaPositive : AppColors.deltaNegative;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$emoji $label $sign$value',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
