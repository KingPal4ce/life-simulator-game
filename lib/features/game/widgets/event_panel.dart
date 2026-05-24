import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../view_models/game_state.dart';
import '../../../models/models.dart';
import 'modern_card.dart';
import 'event_header.dart';

class EventPanel extends StatelessWidget {
  final GameState state;

  const EventPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isGeneratingEvent) {
      return ModernCard(
        child: const Center(
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
        ),
      );
    }

    final event = state.currentEvent;
    if (event == null) {
      return ModernCard(
        child: Center(
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
        ),
      );
    }

    return _CurrentEventPanel(state: state, event: event);
  }
}

class _CurrentEventPanel extends StatelessWidget {
  final GameState state;
  final GameEvent event;

  const _CurrentEventPanel({required this.state, required this.event});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ModernCardHeader(
            label: '✦  CURRENT EVENT',
            startColor: AppColors.eventHeaderStart,
            endColor: AppColors.eventHeaderEnd,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  EventHeader(title: event.title, description: event.description),
                  const SizedBox(height: 16),
                  ...event.options.map(
                    (opt) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _ChoiceButton(
                        text: opt.text,
                        onPressed: () => state.selectOption(opt),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
