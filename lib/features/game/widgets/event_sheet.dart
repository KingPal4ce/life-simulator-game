import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../view_models/game_state.dart';
import '../../../models/models.dart';
import 'event_header.dart';

class EventSheet extends StatelessWidget {
  final VoidCallback onContinue;

  const EventSheet({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.65),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _buildHeader(state),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: _buildContent(state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(GameState state) {
    final isOutcome = state.currentConsequence != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOutcome
              ? [AppColors.outcomeHeaderStart, AppColors.outcomeHeaderEnd]
              : [AppColors.eventHeaderStart, AppColors.eventHeaderEnd],
        ),
      ),
      child: Text(
        isOutcome ? '🏆  OUTCOME' : '✦  CURRENT EVENT',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildContent(GameState state) {
    if (state.isGeneratingEvent) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.eventHeaderStart),
            SizedBox(height: 16),
            Text(
              'Generating life event...',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state.currentConsequence != null) {
      return _OutcomeContent(state: state, onContinue: onContinue);
    }

    final event = state.currentEvent;
    if (event == null) {
      return _ErrorContent(state: state);
    }

    return _EventContent(state: state, event: event);
  }
}

class _EventContent extends StatelessWidget {
  final GameState state;
  final GameEvent event;

  const _EventContent({required this.state, required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EventHeader(title: event.title, description: event.description),
        const SizedBox(height: 20),
        ...event.options.map(
          (opt) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ChoiceButton(
              text: opt.text,
              onPressed: () => state.selectOption(opt),
            ),
          ),
        ),
      ],
    );
  }
}

class _OutcomeContent extends StatelessWidget {
  final GameState state;
  final VoidCallback onContinue;

  const _OutcomeContent({required this.state, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final consequence = state.currentConsequence!;
    final opt = state.lastChosenOption;
    final deltas = _buildDeltas(opt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          consequence,
          style: const TextStyle(
            fontSize: 14,
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
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textSecondary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          onPressed: onContinue,
          child: const Text('Close'),
        ),
      ],
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

class _ErrorContent extends StatelessWidget {
  final GameState state;

  const _ErrorContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Event generation failed.\nCheck your API key.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.selectedChoice,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => state.loadOrStartGame(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _ChoiceButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ),
    );
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
