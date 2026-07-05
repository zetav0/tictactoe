import 'dart:typed_data';
import 'package:flutter/foundation.dart' show compute, kIsWeb;
import '../models/game_model.dart';
import '../utils/connect_four_logic.dart';

/// Connect Four AI. The AI always plays [CellValue.o].
///
/// easy   → random column
/// medium → win now / block now / prefer centre (1-ply tactics)
/// hard   → iterative-deepening negamax with alpha-beta pruning, centre-first
///          move ordering and window-based evaluation, searched in an isolate
///          under a fixed time budget (reaches ~depth 10-13 on a phone).
class ConnectFourAI {
  static Future<int> getBestColumn(
      List<CellValue> board, AIDifficulty difficulty) async {
    final valid = _validCols(board);
    if (valid.isEmpty) return -1;

    switch (difficulty) {
      case AIDifficulty.easy:
        return (List<int>.from(valid)..shuffle()).first;
      case AIDifficulty.medium:
        return _mediumMove(board, valid);
      case AIDifficulty.hard:
        if (valid.length == 1) return valid.first;
        // compute() falls back to the calling thread on web, so keep the
        // budget short there; on mobile the search runs in its own isolate.
        return compute(_searchEntry, (board, kIsWeb ? 200 : 450));
    }
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
    return (List<int>.from(valid)
          ..sort((a, b) => (a - 3).abs().compareTo((b - 3).abs())))
        .first;
  }

  static List<int> _validCols(List<CellValue> board) =>
      [for (int c = 0; c < c4Cols; c++) if (c4DropRow(board, c) >= 0) c];
}

// ───────────────────────────── hard-level solver ─────────────────────────────
// Everything below runs inside `compute`, so it is top-level and self-contained.

int _searchEntry((List<CellValue>, int) request) {
  final (board, budgetMs) = request;
  return _Solver(board, budgetMs).bestColumn();
}

/// Centre-first column order — dramatically improves alpha-beta pruning.
const List<int> _kOrder = [3, 2, 4, 1, 5, 0, 6];
const int _kWinScore = 1000000;

/// Evaluation weights for a window holding N own pieces and no opponent piece.
/// Opponent threats weigh more so the engine plays solid defence at the horizon.
const List<int> _kOwnScore = [0, 1, 10, 50];
const List<int> _kOppScore = [0, 1, 10, 80];

/// All 69 four-cell windows of the board, flattened with stride 4.
final Int32List _kWindows = _buildWindows();

Int32List _buildWindows() {
  final out = <int>[];
  void add(int a, int b, int c, int d) => out.addAll([a, b, c, d]);
  for (int r = 0; r < c4Rows; r++) {
    for (int c = 0; c <= c4Cols - 4; c++) {
      final i = r * c4Cols + c;
      add(i, i + 1, i + 2, i + 3); // horizontal
    }
  }
  for (int r = 0; r <= c4Rows - 4; r++) {
    for (int c = 0; c < c4Cols; c++) {
      final i = r * c4Cols + c;
      add(i, i + c4Cols, i + 2 * c4Cols, i + 3 * c4Cols); // vertical
    }
  }
  for (int r = 0; r <= c4Rows - 4; r++) {
    for (int c = 0; c <= c4Cols - 4; c++) {
      final i = r * c4Cols + c;
      add(i, i + c4Cols + 1, i + 2 * (c4Cols + 1), i + 3 * (c4Cols + 1)); // ↘
    }
    for (int c = 3; c < c4Cols; c++) {
      final i = r * c4Cols + c;
      add(i, i + c4Cols - 1, i + 2 * (c4Cols - 1), i + 3 * (c4Cols - 1)); // ↙
    }
  }
  return Int32List.fromList(out);
}

class _TimeUp implements Exception {
  const _TimeUp();
}

class _Solver {
  /// 0 = empty, 1 = AI (O), 2 = human (X); row 0 is the top row.
  final Int8List _cells = Int8List(c4Rows * c4Cols);

  /// Next drop row per column, -1 when the column is full.
  final Int8List _heights = Int8List(c4Cols);

  final int _budgetMs;
  final Stopwatch _clock = Stopwatch();
  int _nodes = 0;
  int _empty = 0;

  _Solver(List<CellValue> board, this._budgetMs) {
    for (int i = 0; i < board.length; i++) {
      _cells[i] = switch (board[i]) {
        CellValue.o => 1,
        CellValue.x => 2,
        CellValue.empty => 0,
      };
      if (_cells[i] == 0) _empty++;
    }
    for (int c = 0; c < c4Cols; c++) {
      int r = c4Rows - 1;
      while (r >= 0 && _cells[r * c4Cols + c] != 0) {
        r--;
      }
      _heights[c] = r;
    }
  }

  int bestColumn() {
    _clock.start();
    final rootMoves = [
      for (final c in _kOrder)
        if (_heights[c] >= 0) c
    ];
    int best = rootMoves.first;

    for (int depth = 1; depth <= _empty; depth++) {
      // Principal variation first: retry last iteration's best move before
      // the rest so alpha rises early and pruning bites harder.
      rootMoves
        ..remove(best)
        ..insert(0, best);

      int alpha = -2 * _kWinScore;
      int iterBest = rootMoves.first;
      try {
        for (final col in rootMoves) {
          final s = _scoreMove(col, 1, depth, alpha, 2 * _kWinScore, 1);
          if (s > alpha) {
            alpha = s;
            iterBest = col;
          }
        }
      } on _TimeUp {
        return best; // keep the choice of the last fully-searched depth
      }
      best = iterBest;
      // Forced win/loss proven — deeper search cannot change the outcome.
      if (alpha >= _kWinScore - 64 || alpha <= -(_kWinScore - 64)) break;
    }
    return best;
  }

  /// Plays [col] for [color], scores it from [color]'s perspective, unplays it.
  int _scoreMove(int col, int color, int depth, int alpha, int beta, int ply) {
    final row = _heights[col];
    final idx = row * c4Cols + col;
    _cells[idx] = color;
    _heights[col] = row - 1;
    final int s;
    if (_winAt(row, col, color)) {
      s = _kWinScore - ply; // prefer the fastest win
    } else {
      s = -_negamax(depth - 1, -beta, -alpha, 3 - color, ply + 1);
    }
    _cells[idx] = 0;
    _heights[col] = row;
    return s;
  }

  int _negamax(int depth, int alpha, int beta, int color, int ply) {
    if ((++_nodes & 1023) == 0 && _clock.elapsedMilliseconds >= _budgetMs) {
      throw const _TimeUp();
    }

    bool any = false;
    for (int c = 0; c < c4Cols; c++) {
      if (_heights[c] >= 0) {
        any = true;
        break;
      }
    }
    if (!any) return 0; // draw
    if (depth == 0) return color == 1 ? _evaluate() : -_evaluate();

    int best = -2 * _kWinScore;
    for (final col in _kOrder) {
      if (_heights[col] < 0) continue;
      final s = _scoreMove(col, color, depth, alpha, beta, ply);
      if (s > best) best = s;
      if (best > alpha) alpha = best;
      if (alpha >= beta) break;
    }
    return best;
  }

  bool _winAt(int row, int col, int color) {
    // Vertical — only below, nothing sits above a just-placed piece.
    int n = 1;
    for (int r = row + 1; r < c4Rows && _cells[r * c4Cols + col] == color; r++) {
      n++;
    }
    if (n >= 4) return true;
    // Horizontal
    n = 1;
    for (int c = col - 1; c >= 0 && _cells[row * c4Cols + c] == color; c--) {
      n++;
    }
    for (int c = col + 1; c < c4Cols && _cells[row * c4Cols + c] == color; c++) {
      n++;
    }
    if (n >= 4) return true;
    // Diagonal ↘
    n = 1;
    for (int r = row - 1, c = col - 1;
        r >= 0 && c >= 0 && _cells[r * c4Cols + c] == color;
        r--, c--) {
      n++;
    }
    for (int r = row + 1, c = col + 1;
        r < c4Rows && c < c4Cols && _cells[r * c4Cols + c] == color;
        r++, c++) {
      n++;
    }
    if (n >= 4) return true;
    // Diagonal ↙
    n = 1;
    for (int r = row - 1, c = col + 1;
        r >= 0 && c < c4Cols && _cells[r * c4Cols + c] == color;
        r--, c++) {
      n++;
    }
    for (int r = row + 1, c = col - 1;
        r < c4Rows && c >= 0 && _cells[r * c4Cols + c] == color;
        r++, c--) {
      n++;
    }
    return n >= 4;
  }

  /// Static evaluation from the AI's (color 1) perspective.
  int _evaluate() {
    int score = 0;
    for (int r = 0; r < c4Rows; r++) {
      final v = _cells[r * c4Cols + 3];
      if (v == 1) {
        score += 4;
      } else if (v == 2) {
        score -= 4;
      }
    }
    for (int w = 0; w < _kWindows.length; w += 4) {
      int own = 0, opp = 0;
      for (int k = 0; k < 4; k++) {
        final v = _cells[_kWindows[w + k]];
        if (v == 1) {
          own++;
        } else if (v == 2) {
          opp++;
        }
      }
      if (own > 0 && opp > 0) continue; // dead window
      if (own > 0) {
        score += _kOwnScore[own];
      } else if (opp > 0) {
        score -= _kOppScore[opp];
      }
    }
    return score;
  }
}
