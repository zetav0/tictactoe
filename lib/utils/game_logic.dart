import '../models/game_model.dart';

(GameStatus, List<int>?) evaluateMove(List<CellValue> board, CellValue player) {
  for (final combo in GameState.winCombinations) {
    if (board[combo[0]] == player &&
        board[combo[1]] == player &&
        board[combo[2]] == player) {
      return (
        player == CellValue.x ? GameStatus.xWins : GameStatus.oWins,
        combo,
      );
    }
  }
  if (board.every((c) => c != CellValue.empty)) return (GameStatus.draw, null);
  return (GameStatus.playing, null);
}
