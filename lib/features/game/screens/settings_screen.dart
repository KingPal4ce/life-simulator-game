import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../view_models/game_state.dart';

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

class _ThemePackData {
  final String name;
  final String? key;
  final String tagline;
  final bool locked;

  const _ThemePackData({
    required this.name,
    required this.key,
    required this.tagline,
    required this.locked,
  });
}

const List<_ThemePackData> _themePacks = [
  _ThemePackData(
    name: 'Modern Life',
    key: null,
    tagline: 'The classic. Real life, no filter.',
    locked: false,
  ),
  _ThemePackData(
    name: 'Cyberpunk Life',
    key: 'cyberpunk',
    tagline: 'Neural implants. Megacorps. Neon rain.',
    locked: true,
  ),
  _ThemePackData(
    name: 'Medieval Life',
    key: 'medieval',
    tagline: 'Plagues, trades, and noble blood.',
    locked: true,
  ),
  _ThemePackData(
    name: 'Horror Pack',
    key: 'horror',
    tagline: 'Something is watching you.',
    locked: true,
  ),
  _ThemePackData(
    name: 'Celebrity Glam',
    key: 'celebrity',
    tagline: 'Fame, scandal, and the price of it all.',
    locked: true,
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class SettingsScreen extends StatelessWidget {
  final GameState state;

  const SettingsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.navyBackground,
        foregroundColor: AppColors.textOnDark,
        elevation: 0,
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: AppColors.accentYellow,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textOnDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(label: 'THEME PACK'),
            const SizedBox(height: 12),
            ..._themePacks.map(
              (pack) {
                final isUnlocked = pack.key == null || (state.unlockedThemes[pack.key] == true);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ThemePackTile(
                    pack: pack,
                    isSelected: state.selectedTheme == pack.key,
                    isLocked: !isUnlocked,
                    onTap: () => _handlePackTap(context, pack, isUnlocked),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            const Text(
              'Change takes effect next life.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textOnDarkMuted,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePackTap(BuildContext context, _ThemePackData pack, bool isUnlocked) {
    if (!isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${pack.name} — Coming soon!',
            style: const TextStyle(color: AppColors.textOnDark),
          ),
          backgroundColor: AppColors.navyBackground,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    // Tapping the already-selected pack deselects it (back to Modern Life / null).
    final newTheme = (state.selectedTheme == pack.key) ? null : pack.key;
    state.setTheme(newTheme);
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.accentYellow,
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }
}

class _ThemePackTile extends StatelessWidget {
  final _ThemePackData pack;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const _ThemePackTile({
    required this.pack,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool unlocked = !isLocked;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.selectedChoice.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.selectedChoice
                : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.selectedChoice : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.selectedChoice
                      : AppColors.textOnDarkMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.name,
                    style: TextStyle(
                      color: unlocked
                          ? AppColors.textOnDark
                          : AppColors.textOnDarkMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pack.tagline,
                    style: const TextStyle(
                      color: AppColors.textOnDarkMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Lock badge or selected checkmark area
            if (isLocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.lock_outline, size: 11, color: AppColors.textOnDarkMuted),
                    SizedBox(width: 4),
                    Text(
                      'Soon',
                      style: TextStyle(
                        color: AppColors.textOnDarkMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
