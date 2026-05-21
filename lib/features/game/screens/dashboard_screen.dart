import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/game_state.dart';
import '../widgets/top_bar.dart';
import '../widgets/life_tab.dart';
import '../widgets/logs_tab.dart';
import 'death_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (!state.isDead) TopBar(state: state),
            if (state.isDead)
              Expanded(child: DeathScreen(state: state))
            else
              Expanded(child: _buildBody(state)),
          ],
        ),
      ),
      bottomNavigationBar: state.isDead
          ? null
          : BottomNavigationBar(
              backgroundColor: const Color(0xFF1C1F24),
              selectedItemColor: Colors.amber,
              unselectedItemColor: Colors.white54,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Life',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Logs',
                ),
              ],
            ),
    );
  }

  Widget _buildBody(GameState state) {
    return switch (_currentIndex) {
      0 => LifeTab(state: state),
      _ => LogsTab(state: state),
    };
  }
}
