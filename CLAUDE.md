# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app
flutter run

# Analyze / lint
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/features/game/game_state_test.dart
```

## Environment Setup

The app requires a `.env` file in the project root (excluded from git):

```
GEMINI_API_KEY=your_key_here
```

The key is loaded at startup via `flutter_dotenv`. The `.env` file is declared as a Flutter asset in `pubspec.yaml`, so it must exist before `flutter run` or `flutter build` — missing it causes an asset-not-found error at launch.

## Architecture

This is a single-screen Flutter life simulator. A player ages from 0 to 100, making choices at each age that alter four stats (happiness, health, smarts, looks). Death triggers when health hits 0 or age reaches 100.

### Data flow

```
main.dart
  └─ initializes LocalStorageService (Hive) + AIService (Gemini)
  └─ wires concrete impls into GameState via IAIService / ILocalStorageService interfaces
  └─ provides GameState (ChangeNotifier) via Provider

GameState  ←─ the only state object; screens/widgets read it via context.watch<GameState>()
  ├─ calls AIService to generate events and the end-of-life story
  ├─ calls StatsManager to apply stat deltas (clamped 0–100)
  └─ persists to / restores from LocalStorageService after every state change
```

### Key files

| File | Role |
|------|------|
| `lib/models/models.dart` | All domain types: `PlayerStats`, `GameEvent`, `EventOption`, `Decision` |
| `lib/services/ai_service.dart` | Two Gemini 2.5 Flash models — `_eventModel` (structured JSON schema) and `_storyModel` (free-form prose, temperature 1.0) |
| `lib/services/local_storage_service.dart` | Hive box wrapper; serialises `PlayerStats` + `previousOutcome` as JSON strings |
| `lib/services/interfaces.dart` | `IAIService` and `ILocalStorageService` abstract interfaces |
| `lib/features/stats/stats_manager.dart` | Stateless helper; single method `applyOptionEffects` that clamps all four stats |
| `lib/features/game/view_models/game_state.dart` | Central `ChangeNotifier`; owns the full game loop |
| `lib/features/game/screens/dashboard_screen.dart` | Tab host: **Life** tab (stats + event panel) and **Logs** tab; swaps to `DeathScreen` when `isDead` |
| `lib/features/game/screens/death_screen.dart` | Game-over screen showing final stats, achievements, AI-generated life story, and full life log |
| `lib/features/game/widgets/life_log_list_view.dart` | Extracted widget; renders a `List<String>` log with consistent styling |
| `lib/core/app_colors.dart` | Single source of truth for all UI colors — use `AppColors.*` constants, never raw hex values |

### Game loop (inside `GameState`)

1. `loadOrStartGame()` — restores Hive session or calls `startGame()`
2. `_triggerNextEvent()` — calls `AIService.generateNextEvent()` with the last 5 decisions as context; guarded by `isGeneratingEvent` flag to prevent concurrent calls; retries up to 3 times with 1 s exponential backoff before setting `eventGenerationFailed`
3. `selectOption(option)` — applies stat effects via `StatsManager`, records a `Decision`, saves state
4. `continueToNextEvent()` — advances `previousOutcome`, calls `_ageUp()`
5. `_ageUp()` — runs `_checkAchievements()`, increments age, checks death; if alive repeats from step 2, if dead calls `_triggerLifeStory()`

`endLife()` is a separate entry point (player-initiated death): sets health to 0 and jumps directly to `_triggerLifeStory()`, bypassing `_ageUp()`.

### State mutation

`PlayerStats` fields are mutable (`var`, not `final`). `StatsManager.applyOptionEffects` and `GameState` mutate the `stats` object in place, then call `notifyListeners()`. Lists (`lifeLog`, `decisions`, `achievements`) are always replaced with new `List.from(...)` copies before mutation to trigger change detection correctly.

### AI event generation

`AIService` uses Gemini's structured output (via `responseSchema`) so event JSON is always well-typed without manual parsing guards. The prompt intentionally breaks direct cause-and-effect 40% of the time (`useDirectContext` flag) to keep events feeling varied.

`EventOption` fields all default to 0 / empty string, and `fromJson()` uses null coalescing, so incomplete event JSON never crashes at parse time.

### Achievements

Achievements are data-driven: `_achievementDefs` in `GameState` is a `List<({String name, bool Function(PlayerStats) condition})>`. `_checkAchievements()` iterates the list and unlocks any whose predicate returns true and whose name isn't already in `stats.achievements`. To add an achievement, append a new record to `_achievementDefs` — no other code change needed.

Currently defined: `'Centenarian in Training'` (age ≥ 80) and `'Absolute Bliss'` (happiness == 100).

### Schema versioning

`PlayerStats` includes `static const int schemaVersion = 1`. `toJson()` writes it; `fromJson()` throws `FormatException` if the version field is absent or mismatched. Increment the constant and add migration logic in `fromJson()` whenever the stored shape changes.

### UI conventions

- NES-style theme via `nes_ui` package (`flutterNesTheme()`); use `NesButton` and `RetroContainer` for any new interactive or card-like elements. `RetroContainer` is a thin local wrapper around `NesContainer` with dark background defaults.
- All widgets receive `GameState` (or a slice of it) as a constructor parameter — no `context.watch` inside leaf widgets.
- All colors must come from `AppColors` (`darkBackground`, `cardBackground`, `sectionHeader`, `eventHeader`, `logTextOnLight`, `logTextOnDark`).

### Testing

Three test files: `game_state_test.dart` (game loop, retry, achievements, in-flight guard), `models_test.dart` (serialization, schema validation), `stats_manager_test.dart` (stat clamping).

Tests use in-file fake implementations (`FakeAIService`, `FakeLocalStorageService`) — no mocking library. Fakes accept constructor params like `failFirstNCalls` to simulate retry scenarios. Pass `retryDelay: Duration.zero` to `GameState` in tests to skip backoff delays. Use `Future.delayed(Duration.zero)` in tests to flush the microtask queue after async calls.
