import 'dart:async';
import '../models/game_model.dart';
import '../services/connect_four_ai.dart';
import '../services/sound_service.dart';
import '../utils/connect_four_logic.dart';
import 'connect_four_base_controller.dart';

class ConnectFourController extends ConnectFourBaseController {
  GameState _state;
  final GameMode mode;
  final AIDifficulty difficulty;

  @override
  int? lastPlacedIndex;
  int _moveCount = 0;
  @override
  int get moveCount => _moveCount;

  ConnectFourController({required this.mode, required this.difficulty})
      : _state = GameState(
          board: List.filled(c4Rows * c4Cols, CellValue.empty),
          currentPlayer: CellValue.x,
          status: GameStatus.playing,
          scoreX: 0,
          scoreO: 0,
        );

  @override
  GameState get state => _state;

  @override
  String get player1Label => 'PLAYER 1';

  @override
  String get player2Label => mode == GameMode.pvAi ? 'AI' : 'PLAYER 2';

  @override
  bool get isMyTurn =>
      !(mode == GameMode.pvAi && _state.currentPlayer == CellValue.o);

  @override
  String get turnMessage {
    if (_state.currentPlayer == CellValue.x) return 'Your turn!';
    if (mode == GameMode.pvAi) return 'AI thinking...';
    return 'Player 2\'s turn!';
  }

  /// [col] is 0–6. Drops the current player's piece into that column.
  @override
  void makeMove(int col) {
    if (_state.status != GameStatus.playing) return;
    final row = c4DropRow(_state.board, col);
    if (row < 0) return;

    final index = row * c4Cols + col;
    final newBoard = List<CellValue>.from(_state.board)..[index] = _state.currentPlayer;
    final (status, winLine) = evaluateC4Move(newBoard, _state.currentPlayer);

    lastPlacedIndex = index;
    _moveCount++;

    _state = GameState(
      board: newBoard,
      currentPlayer: _state.currentPlayer == CellValue.x ? CellValue.o : CellValue.x,
      status: status,
      winLine: winLine,
      scoreX: status == GameStatus.xWins ? _state.scoreX + 1 : _state.scoreX,
      scoreO: status == GameStatus.oWins ? _state.scoreO + 1 : _state.scoreO,
    );
    notifyListeners();
    SoundService.instance.playMove();
    if (status != GameStatus.playing) {
      Future.delayed(const Duration(milliseconds: 400), SoundService.instance.playWin);
    }

    if (status == GameStatus.playing && !isMyTurn) {
      Timer(const Duration(milliseconds: 700), _doAiMove);
    }
  }

  void _doAiMove() {
    if (_state.status != GameStatus.playing) return;
    final col = ConnectFourAI.getBestColumn(_state.board, difficulty);
    if (col >= 0) makeMove(col);
  }

  @override
  void reset() {
    lastPlacedIndex = null;
    _moveCount = 0;
    _state = GameState(
      board: List.filled(c4Rows * c4Cols, CellValue.empty),
      currentPlayer: CellValue.x,
      status: GameStatus.playing,
      winLine: null,
      scoreX: _state.scoreX,
      scoreO: _state.scoreO,
    );
    notifyListeners();
  }
}
