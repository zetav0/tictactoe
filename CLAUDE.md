# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter run                  # Android/iOS device or emulator (primary target)
flutter run -d chrome        # Web — the desktop test target (Firebase fully works here)

flutter test                                    # All tests
flutter test test/connect_four_ai_test.dart     # Single test file

flutter analyze
flutter pub get
```

Android, iOS and Web are the only enabled platforms — the desktop folders (`linux/`, `macos/`, `windows/`) were deliberately removed; don't re-add them. The app is portrait-only.

## What this app is

"Game Blast": two games — Tic Tac Toe and Connect Four ("4 en Raya") — each playable as local PvP, vs AI (easy/medium/hard), or online multiplayer over Firebase Realtime Database using 6-character room codes. Users have a profile (username + a preset multiavatar; custom photo upload was deliberately removed to avoid user-generated content) persisted with shared_preferences; app entry (`lib/app.dart`) routes to `ProfileSetupScreen` until a profile exists, then to `MainShell` — an IndexedStack with the three bottom-nav tabs (Play/History/Profile). Game screens are pushed on top of the shell and deliberately have no bottom nav.

## Architecture

The load-bearing abstraction is `BaseGameController` (`lib/controllers/base_controller.dart`), a `ChangeNotifier` exposing state, player labels and turn info, with four implementations:

- `GameController` — local Tic Tac Toe (PvP or vs `AiService`)
- `RemoteGameController` — online Tic Tac Toe over RTDB
- `ConnectFourController` / `RemoteConnectFourController` — the same pair for Connect Four, via `ConnectFourBaseController` which adds `lastPlacedIndex`/`moveCount` for drop animations

Because of this, the game UI (`GameBody`, `ScoreCards`, `TurnIndicator`, `ConnectFourBoard`) is shared between local and online play. Put new game features behind this abstraction.

- **Board model:** `List<CellValue>` — 9 cells for Tic Tac Toe, 42 (6×7, row-major, row 0 = top) for Connect Four. Pure win/draw logic lives in `lib/utils/`.
- **Board rendering:** Tic Tac Toe uses Flame (`lib/game/` — board/cell/win-line components drawn on canvas with glow and animations). Connect Four is plain widgets (`lib/widgets/connect_four_board.dart`).
- **State management:** Riverpod is used only for the profile and home-screen selections (`lib/providers/`). Game state lives in the controllers (`ChangeNotifier` + `ListenableBuilder`), not in Riverpod.
- **AI (the AI always plays O, the human is X; the starting player is chosen at random for every game and rematch, in all modes — when O starts, the controllers kick off the first AI move from the constructor/reset):**
  - `AiService` (TTT): minimax — hard is unbeatable, medium randomly alternates minimax/random.
  - `ConnectFourAI`: easy = random, medium = 1-ply win/block/centre, hard = iterative-deepening negamax with alpha-beta and window-based evaluation, run via `compute()` in an isolate under a time budget (`kIsWeb ? 200 : 450` ms — `compute` falls back to the main thread on web).
- **Online flow:** `RoomService` — the host creates a room (status `waiting`, host = X) and waits in `WaitingRoomScreen`; the joiner validates the room's `gameType` client-side before `confirmJoin` flips status to `playing`. Each client computes its move locally and writes the full state to `rooms/<CODE>`; the opponent receives it via the `onValue` stream. Leaving or cancelling deletes the room.
- **Firebase:** initialized in `main.dart` inside try/catch; the global `firebaseReady` gates the Online button. There is **no firebase_auth** — RTDB security rules must allow unauthenticated access.
- **Sound:** `SoundService` (audioplayers) with the `.wav` assets in `assets/sounds/` (move + win, separate players so they don't cut each other off).
- **Match history:** every finished game is recorded from the controllers into `HistoryService` (ChangeNotifier singleton over shared_preferences, newest first, capped at 50) as a `MatchRecord`; `HistoryScreen` renders it live. `MatchRecord.result` is from the local player's perspective (player 1 locally, own role online).
- **i18n:** English + Spanish via `flutter_localizations`/gen-l10n. Strings live in `lib/l10n/app_en.arb` (template) and `app_es.arb`; code is generated into `lib/l10n/gen/` (`flutter gen-l10n`, also runs automatically on build). Never hardcode user-facing strings: add a key to both ARBs. Controllers must stay locale-free — they expose semantic enums (`PlayerLabel`, `TurnMessage`) that the UI maps to text via `lib/l10n/labels.dart`.

## Design System — "Playful Edition"

Defined in `.stich/stitch_advanced_flutter_tic_tac_toe/playful_edition/DESIGN.md`, implemented in `lib/theme/` (`AppColors`, `PlayfulTheme`, `PlayfulBackground`):

- Royal-blue canvas gradient (#1E4DE2 → #002A78) with a subtle white dot grid; dark neutral surfaces elsewhere
- Font: Plus Jakarta Sans (google_fonts), heavy weights (w700/w800)
- Player X = light blue (#B4C5FF / indigo glow), Player O = yellow (#FFBA38); wins use the green tertiary
- 3-D buttons: solid fill + hard bottom "lip" shadow (`PlayfulTheme.lipShadow` and its primary/secondary/tertiary variants)
- Glassmorphism panels (white ~12% opacity + light border) and hyper-rounded corners: cells 16, cards 24, pill buttons
- Game-over modal: `BackdropFilter` blur(12) over a glass card, `easeOutBack` entrance

## Testing notes

- Widget tests must call `SharedPreferences.setMockInitialValues(...)` before pumping the app — the entry point loads the profile. `app.dart` itself never touches Firebase, so the entry flow needs no Firebase mocks.
- `test/connect_four_ai_test.dart` builds positions with a gravity-respecting `drop()` helper; keep positions legal (X always has one more piece than O when it is O's turn).

## Known gaps

- The leaderboard icons in the app bars are visual placeholders.
- Abandoned online rooms are never garbage-collected server-side (and games abandoned mid-match are not recorded in the history).
