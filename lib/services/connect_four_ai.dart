import 'dart:math' as math;
import '../models/game_model.dart';
import '../utils/connect_four_logic.dart';

class ConnectFourAI {
  static int getBestColumn(List<CellValue> board, AIDifficulty difficulty) {
    final valid = _validCols(board);
    if (valid.isEmpty) return -1;

    return switch (difficulty) {
      AIDifficulty.easy => (List<int>.from(valid)..shuffle()).first,
      AIDifficulty.medium => _mediumMove(board, valid),
      AIDifficulty.hard => _bestMove(board),
    };
  }

  static int _mediumMove(List<CellValue> board, List<int> valid) {
    // Win immediately if possible
    for (final col in valid) {
      final row = c4DropRow(board, col);
      final b = List<CellValue>.from(board)..[row * c4Cols + col] = CellValue.o;
      if (c4FindWin(b, CellValue.o) != null) return col;
    }
    // Block player from winning
    for (final col in valid) {
      final row = c4DropRow(board, col);
      final b = List<CellValue>.from(board)..[row * c4Cols + col] = CellValue.x;
      if (c4FindWin(b, CellValue.x) != null) return col;
    }
    // Prefer center columns
    return (List<int>.from(valid)..sort((a, b) => (a - 3).abs().compareTo((b - 3).abs()))).first;
  }

  static int _bestMove(List<CellValue> board) {
    int best = -99999;
    int bestCol = _validCols(board).first;
    for (final col in _validCols(board)) {
      final row = c4DropRow(board, col);
      final b = List<CellValue>.from(board)..[row * c4Cols + col] = CellValue.o;
      final s = _minimax(b, 5, false, -99999, 99999);
      if (s > best) {
        best = s;
        bestCol = col;
      }
    }
    return bestCol;
  }

  static int _minimax(List<CellValue> board, int depth, bool isMax, int alpha, int beta) {
    // Check if the player who just moved won
    final last = isMax ? CellValue.x : CellValue.o;
    if (c4FindWin(board, last) != null) {
      return last == CellValue.o ? 100 + depth : -(100 + depth);
    }
    if (board.every((c) => c != CellValue.empty) || depth == 0) {
      return _heuristic(board);
    }

    final player = isMax ? CellValue.o : CellValue.x;
    int best = isMax ? -99999 : 99999;

    for (final col in _validCols(board)) {
      final row = c4DropRow(board, col);
      final b = List<CellValue>.from(board)..[row * c4Cols + col] = player;
      final s = _minimax(b, depth - 1, !isMax, alpha, beta);
      best = isMax ? math.max(best, s) : math.min(best, s);
      if (isMax) {
        alpha = math.max(alpha, best);
      } else {
        beta = math.min(beta, best);
      }
      if (beta <= alpha) break;
    }
    return best;
  }

  static int _heuristic(List<CellValue> board) {
    int score = 0;
    // Prefer center column
    for (int r = 0; r < c4Rows; r++) {
      if (board[r * c4Cols + 3] == CellValue.o) score += 3;
      if (board[r * c4Cols + 3] == CellValue.x) score -= 3;
    }
    return score;
  }

  static List<int> _validCols(List<CellValue> board) =>
      [for (int c = 0; c < c4Cols; c++) if (c4DropRow(board, c) >= 0) c];
}
