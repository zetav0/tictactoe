import '../models/game_model.dart';

class AiService {
  static int getBestMove(List<CellValue> board, AIDifficulty difficulty) {
    final available = _available(board);
    if (available.isEmpty) return -1;

    switch (difficulty) {
      case AIDifficulty.easy:
        available.shuffle();
        return available.first;
      case AIDifficulty.medium:
        if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
          return _minimax(board);
        }
        available.shuffle();
        return available.first;
      case AIDifficulty.hard:
        return _minimax(board);
    }
  }

  static int _minimax(List<CellValue> board) {
    // Shuffle so ties (e.g. the opening move) don't always pick the same cell.
    final moves = _available(board)..shuffle();
    int bestScore = -1000;
    int bestMove = moves.first;

    for (final move in moves) {
      final b = List<CellValue>.from(board)..[move] = CellValue.o;
      final score = _score(b, 0, false);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove;
  }

  static int _score(List<CellValue> board, int depth, bool isMax) {
    final winner = _winner(board);
    if (winner == CellValue.o) return 10 - depth;
    if (winner == CellValue.x) return depth - 10;
    if (_available(board).isEmpty) return 0;

    if (isMax) {
      int best = -1000;
      for (final m in _available(board)) {
        final b = List<CellValue>.from(board)..[m] = CellValue.o;
        final s = _score(b, depth + 1, false);
        if (s > best) best = s;
      }
      return best;
    } else {
      int best = 1000;
      for (final m in _available(board)) {
        final b = List<CellValue>.from(board)..[m] = CellValue.x;
        final s = _score(b, depth + 1, true);
        if (s < best) best = s;
      }
      return best;
    }
  }

  static CellValue? _winner(List<CellValue> board) {
    for (final combo in GameState.winCombinations) {
      final a = board[combo[0]];
      if (a != CellValue.empty && a == board[combo[1]] && a == board[combo[2]]) {
        return a;
      }
    }
    return null;
  }

  static List<int> _available(List<CellValue> board) =>
      [for (int i = 0; i < 9; i++) if (board[i] == CellValue.empty) i];
}
