import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';
import '../../../core/app_colors.dart';
import '../view_models/game_state.dart';
import '../../../models/models.dart';
import 'retro_container.dart';
import 'event_header.dart';

class EventPanel extends StatelessWidget {
  final GameState state;

  const EventPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.currentConsequence != null) {
      return _ConsequencePanel(state: state);
    }

    if (state.isGeneratingEvent) {
      return const RetroContainer(
        backgroundColor: Color(0xFFE6E6FA),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.black),
              SizedBox(height: 16),
              Text(
                'Generating life event...',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    final event = state.currentEvent;
    if (event == null) {
      return RetroContainer(
        backgroundColor: const Color(0xFFE6E6FA),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Missing API Key or Event Generation Failed.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              NesButton(
                type: NesButtonType.primary,
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

class _ConsequencePanel extends StatelessWidget {
  final GameState state;

  const _ConsequencePanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final opt = state.lastChosenOption;
    final deltas = <_StatDelta>[
      if (opt != null && opt.happinessEffect != 0)
        _StatDelta(
          Icons.sentiment_very_satisfied,
          'Happiness',
          opt.happinessEffect,
          Colors.green,
        ),
      if (opt != null && opt.healthEffect != 0)
        _StatDelta(
          Icons.favorite,
          'Health',
          opt.healthEffect,
          Colors.redAccent,
        ),
      if (opt != null && opt.smartsEffect != 0)
        _StatDelta(Icons.psychology, 'Smarts', opt.smartsEffect, Colors.orange),
      if (opt != null && opt.looksEffect != 0)
        _StatDelta(Icons.face, 'Looks', opt.looksEffect, Colors.purple),
    ];

    return RetroContainer(
      backgroundColor: const Color(0xFFF4F4F0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.sectionHeader,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              'OUTCOME',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    state.currentConsequence!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.7,
                    ),
                  ),
                  if (deltas.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: deltas
                          .map((d) => _DeltaChip(delta: d))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  NesButton(
                    type: NesButtonType.primary,
                    onPressed: () => state.continueToNextEvent(),
                    child: const Text('Next Year →'),
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

class _CurrentEventPanel extends StatelessWidget {
  final GameState state;
  final GameEvent event;

  const _CurrentEventPanel({required this.state, required this.event});

  @override
  Widget build(BuildContext context) {
    return RetroContainer(
      backgroundColor: const Color(0xFFF4F4F0),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.eventHeader,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              'CURRENT EVENT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  EventHeader(
                    title: event.title,
                    description: event.description,
                  ),
                  const SizedBox(height: 24),
                  ...event.options.map(
                    (opt) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: NesButton(
                        type: NesButtonType.normal,
                        onPressed: () => state.selectOption(opt),
                        child: Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                opt.text,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  height: 1.7,
                                ),
                              ),
                            ),
                          ],
                        ),
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

class _StatDelta {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _StatDelta(this.icon, this.label, this.value, this.color);
}

class _DeltaChip extends StatelessWidget {
  final _StatDelta delta;

  const _DeltaChip({required this.delta});

  @override
  Widget build(BuildContext context) {
    final isPositive = delta.value > 0;
    final sign = isPositive ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPositive
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.red.withValues(alpha: 0.15),
        border: Border.all(
          color: isPositive ? Colors.green : Colors.redAccent,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(delta.icon, size: 14, color: delta.color),
          const SizedBox(width: 4),
          Text(
            '$sign${delta.value}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
