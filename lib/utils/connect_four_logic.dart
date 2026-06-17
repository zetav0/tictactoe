import '../models/game_model.dart';

const int c4Rows = 6;
const int c4Cols = 7;

/// Returns the row where a piece lands in [col], or -1 if the column is full.
int c4DropRow(List<CellValue> board, int col) {
  for (int row = c4Rows - 1; row >= 0; row--) {
    if (board[row * c4Cols + col] == CellValue.empty) return row;
  }
  return -1;
}

/// Returns the 4 winning cell indices if [player] has four in a row, else null.
List<int>? c4FindWin(List<CellValue> board, CellValue player) {
  // Horizontal
  for (int r = 0; r < c4Rows; r++) {
    for (int c = 0; c <= c4Cols - 4; c++) {
      final w = [r * c4Cols + c, r * c4Cols + c + 1, r * c4Cols + c + 2, r * c4Cols + c + 3];
      if (w.every((i) => board[i] == player)) return w;
    }
  }
  // Vertical
  for (int r = 0; r <= c4Rows - 4; r++) {
    for (int c = 0; c < c4Cols; c++) {
      final w = [r * c4Cols + c, (r + 1) * c4Cols + c, (r + 2) * c4Cols + c, (r + 3) * c4Cols + c];
      if (w.every((i) => board[i] == player)) return w;
    }
  }
  // Diagonal ↘
  for (int r = 0; r <= c4Rows - 4; r++) {
    for (int c = 0; c <= c4Cols - 4; c++) {
      final w = [
        r * c4Cols + c,
        (r + 1) * c4Cols + (c + 1),
        (r + 2) * c4Cols + (c + 2),
        (r + 3) * c4Cols + (c + 3),
      ];
      if (w.every((i) => board[i] == player)) return w;
    }
  }
  // Diagonal ↙
  for (int r = 0; r <= c4Rows - 4; r++) {
    for (int c = 3; c < c4Cols; c++) {
      final w = [
        r * c4Cols + c,
        (r + 1) * c4Cols + (c - 1),
        (r + 2) * c4Cols + (c - 2),
        (r + 3) * c4Cols + (c - 3),
      ];
      if (w.every((i) => board[i] == player)) return w;
    }
  }
  return null;
}

/// Evaluates the board after [player] just moved.
(GameStatus, List<int>?) evaluateC4Move(List<CellValue> board, CellValue player) {
  final win = c4FindWin(board, player);
  if (win != null) {
    return (player == CellValue.x ? GameStatus.xWins : GameStatus.oWins, win);
  }
  if (board.every((c) => c != CellValue.empty)) return (GameStatus.draw, null);
  return (GameStatus.playing, null);
}
