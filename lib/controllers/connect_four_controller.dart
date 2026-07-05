import 'dart:async';
import 'dart:math';
import '../models/game_model.dart';
import '../services/connect_four_ai.dart';
import '../services/sound_service.dart';
import '../utils/connect_four_logic.dart';
import 'base_controller.dart';
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
          currentPlayer: _randomStarter(),
          status: GameStatus.playing,
          scoreX: 0,
          scoreO: 0,
        ) {
    _scheduleAiMoveIfNeeded();
  }

  static CellValue _randomStarter() =>
      Random().nextBool() ? CellValue.x : CellValue.o;

  void _scheduleAiMoveIfNeeded() {
    if (_state.status == GameStatus.playing && !isMyTurn) {
      // Hard spends ~½s searching in an isolate, so it starts sooner; the
      // total response time stays close to the simpler levels' fixed delay.
      final delayMs = difficulty == AIDifficulty.hard ? 250 : 700;
      Timer(Duration(milliseconds: delayMs), _doAiMove);
    }
  }

  @override
  GameState get state => _state;

  @override
  PlayerLabel get player1Label => PlayerLabel.player1;

  @override
  PlayerLabel get player2Label =>
      mode == GameMode.pvAi ? PlayerLabel.ai : PlayerLabel.player2;

  @override
  bool get isMyTurn =>
      !(mode == GameMode.pvAi && _state.currentPlayer == CellValue.o);

  @override
  TurnMessage get turnMessage {
    if (_state.currentPlayer == CellValue.x) return TurnMessage.yourTurn;
    if (mode == GameMode.pvAi) return TurnMessage.aiThinking;
    return TurnMessage.player2Turn;
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

    _scheduleAiMoveIfNeeded();
  }

  Future<void> _doAiMove() async {
    if (_state.status != GameStatus.playing || isMyTurn) return;
    final col = await ConnectFourAI.getBestColumn(_state.board, difficulty);
    // The game may have been reset or closed while the search was running.
    if (_disposed || _state.status != GameStatus.playing || isMyTurn) return;
    if (col >= 0) makeMove(col);
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void reset() {
    lastPlacedIndex = null;
    _moveCount = 0;
    _state = GameState(
      board: List.filled(c4Rows * c4Cols, CellValue.empty),
      currentPlayer: _randomStarter(),
      status: GameStatus.playing,
      winLine: null,
      scoreX: _state.scoreX,
      scoreO: _state.scoreO,
    );
    notifyListeners();
    _scheduleAiMoveIfNeeded();
  }
}
