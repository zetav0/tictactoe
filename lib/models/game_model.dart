enum CellValue { empty, x, o }

enum GameMode { pvp, pvAi }

enum AIDifficulty { easy, medium, hard }

enum GameStatus { playing, xWins, oWins, draw }

enum GameType { ticTacToe, connectFour }

class GameState {
  final List<CellValue> board;
  final CellValue currentPlayer;
  final GameStatus status;
  final List<int>? winLine;
  final int scoreX;
  final int scoreO;

  const GameState({
    required this.board,
    required this.currentPlayer,
    required this.status,
    this.winLine,
    this.scoreX = 0,
    this.scoreO = 0,
  });

  static const List<List<int>> winCombinations = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6],
  ];
}
