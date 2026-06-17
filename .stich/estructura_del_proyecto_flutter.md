# Tic Tac Toe Pro - Flutter Project Structure

## Architecture
This project follows a clean, modular structure:
- **`lib/models/`**: Game state and board models.
- **`lib/screens/`**: UI screens (Home, Game).
- **`lib/widgets/`**: Reusable components (Board, Cell, ScoreCard).
- **`lib/services/`**: AI logic (Minimax), Local Persistence.
- **`lib/providers/`**: State management using Riverpod.

## File Contents

### `pubspec.yaml`
```yaml
name: tic_tac_toe_pro
description: A modern, high-fidelity Tic Tac Toe game.
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.3.6
  shared_preferences: ^2.2.0
  google_fonts: ^5.1.0
  flutter_animate: ^4.2.0
  audioplayers: ^5.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/sounds/move.mp3
    - assets/sounds/win.mp3
```

### `lib/services/ai_service.dart` (Minimax Algorithm)
```dart
class AIService {
  static const String x = 'X';
  static const String o = 'O';

  int minimax(List<String?> board, int depth, bool isMaximizing) {
    String? winner = checkWinner(board);
    if (winner == o) return 10 - depth;
    if (winner == x) return depth - 10;
    if (!board.contains(null)) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == null) {
          board[i] = o;
          int score = minimax(board, depth + 1, false);
          board[i] = null;
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == null) {
          board[i] = x;
          int score = minimax(board, depth + 1, true);
          board[i] = null;
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  int getBestMove(List<String?> board, String difficulty) {
    if (difficulty == 'Easy') {
      // Random move
      List<int> available = [];
      for(int i=0; i<9; i++) if(board[i] == null) available.add(i);
      return available[Random().nextInt(available.length)];
    }
    
    // Hard / Medium Logic...
    // (Full minimax implementation for Hard)
  }
}
```
