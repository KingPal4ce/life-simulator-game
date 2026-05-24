import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../view_models/game_state.dart';
import '../widgets/top_bar.dart';
import '../widgets/stats_panel.dart';
import '../widgets/life_log_list_view.dart';
import '../widgets/life_progression_bar.dart';
import '../widgets/modern_card.dart';
import '../widgets/event_sheet.dart';
import 'death_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _sheetOpen = false;
  late final GameState _gameState;

  @override
  void initState() {
    super.initState();
    _gameState = context.read<GameState>();
    _gameState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _gameState.removeListener(_onStateChange);
    super.dispose();
  }

  // Handles death triggered outside the sheet (e.g. surrender dialog).
  // _sheetOpen is set to false immediately so the onContinue guard in the
  // sheet won't attempt a redundant pop.
  void _onStateChange() {
    if (!mounted) return;
    if (_gameState.isDead && _sheetOpen) {
      _sheetOpen = false;
      Navigator.of(context).pop();
    }
  }

  void _openSheet() {
    if (_sheetOpen || !mounted) return;

    // Advance the year if the player hasn't yet after viewing their outcome.
    if (_gameState.currentConsequence != null) {
      _gameState.continueToNextEvent();
      // Death can occur during continueToNextEvent (age 100, health 0).
      // The dashboard will rebuild into DeathScreen on the next frame.
      if (_gameState.isDead) return;
    }

    if (_gameState.isDead) return;

    _sheetOpen = true;
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChangeNotifierProvider<GameState>.value(
        value: _gameState,
        child: EventSheet(
          onContinue: () {
            // Guard: if the parent already set _sheetOpen = false (death via
            // endLife), skip the redundant pop.
            if (!_sheetOpen) return;
            _sheetOpen = false;
            Navigator.of(context).pop();
          },
        ),
      ),
    ).then((_) => _sheetOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!state.isDead) TopBar(state: state),
            if (state.isDead)
              Expanded(child: DeathScreen(state: state))
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: StatsPanel(stats: state.stats),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _buildLifeLogCard(context, state),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: _buildAgeUpButton(),
              ),
              LifeProgressionBar(age: state.stats.age),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAgeUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.selectedChoice,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          elevation: 2,
        ),
        onPressed: _openSheet,
        child: const Text('Age Up →'),
      ),
    );
  }

  Widget _buildLifeLogCard(BuildContext context, GameState state) {
    const int previewCount = 5;
    final logs = state.stats.lifeLog;
    final needsViewAll = logs.length > previewCount;

    return ModernCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ModernCardHeader(
            label: '📖  LIFE LOG',
            startColor: AppColors.logHeaderStart,
            endColor: AppColors.logHeaderEnd,
          ),
          Expanded(
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: logs.isEmpty
                      ? const Text(
                          'Your story begins here...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : LifeLogListView(
                          entries: logs,
                          maxEntries: previewCount,
                        ),
                ),
              ),
            ),
          ),
          if (needsViewAll)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showFullLog(context, state),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.logHeaderStart,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('View all ↓'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFullLog(BuildContext context, GameState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Full Life Log',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    LifeLogListView(entries: state.stats.lifeLog),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
