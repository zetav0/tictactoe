# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app (hot reload available with 'r' in terminal)
flutter run

# Run on a specific device (mobile-first project; Chrome is the desktop test target)
flutter run -d chrome        # Web

# Tests
flutter test                          # All tests
flutter test test/widget_test.dart    # Single test file

# Analysis and linting
flutter analyze

# Install/update dependencies
flutter pub get
flutter pub upgrade
```

## Architecture

This is a Flutter Tic Tac Toe game. The current `lib/main.dart` is still the default counter demo — the game is being built from scratch. The intended structure is defined in `.stich/estructura_del_proyecto_flutter.md`:

```
lib/
  models/       # Game state and board models
  screens/      # HomeScreen, GameScreen
  widgets/      # Board, Cell, ScoreCard, GameSymbol
  services/     # AIService (Minimax), local persistence (shared_preferences)
  providers/    # Riverpod state management
```

**State management:** Riverpod (`flutter_riverpod`). All game state flows through providers, not `setState` in screen widgets.

**AI service:** `AIService` in `lib/services/ai_service.dart` implements Minimax. Easy difficulty uses random moves; Hard uses full Minimax. The board is represented as `List<String?>` with 9 elements (null = empty, 'X'/'O' = taken).

**Animations:** Use the `flutter_animate` package. Reference implementations for piece entry (scale + fadeIn), cell tap feedback, winning cell pulse, and turn indicator shake are in `.stich/c_digo_de_animaciones_para_flutter.md`.

## Design System — "Indigo-Coral Play"

Defined in `.stich/indigo_coral_play/DESIGN.md`. Key points:

- **Player X = Indigo** (`primary: #4f378a` / `Colors.indigoAccent`), **Player O = Coral** (`Colors.coral`)
- **Font:** Inter (via `google_fonts`)
- **Shape language:** Extra-rounded everywhere — cells use `BorderRadius.circular(16)`, buttons use pill/full-round, modals use `BorderRadius.circular(24)`
- **Winning cells:** pulse animation with `Colors.indigoAccent` glow; winning line animates in using Success Green
- **Game-over modals:** glassmorphism overlay — `backdrop-filter blur(12px)`, semi-transparent surface container
- **Board layout:** 3×3 grid with 12px gutters, 20px screen margins, 8px vertical rhythm base unit; board capped at 500px max-width on tablets

## Dependencies to Add

The following packages are planned but not yet in `pubspec.yaml`:

```yaml
flutter_riverpod: ^2.3.6
shared_preferences: ^2.2.0
google_fonts: ^5.1.0
flutter_animate: ^4.2.0
audioplayers: ^5.2.1
```

Sound assets go in `assets/sounds/move.mp3` and `assets/sounds/win.mp3`.

## Design References

`.stich/` holds pre-built HTML mockups with screenshots:
- `.stich/men_principal/` — main menu screen
- `.stich/tablero_de_juego/` — game board screen
- `.stich/tic_tac_toe_logo/` — logo
