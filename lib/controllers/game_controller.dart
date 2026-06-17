import 'dart:async';
import '../models/game_model.dart';
import '../services/ai_service.dart';
import '../services/sound_service.dart';
import '../utils/game_logic.dart';
import 'base_controller.dart';

class GameController extends BaseGameController {
  GameState _state;
  final GameMode mode;
  final AIDifficulty difficulty;

  GameController({required this.mode, required this.difficulty})
      : _state = GameState(
          board: List.filled(9, CellValue.empty),
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

  @override
  void makeMove(int index) {
    if (_state.status != GameStatus.playing) return;
    if (_state.board[index] != CellValue.empty) return;

    final newBoard = List<CellValue>.from(_state.board)..[index] = _state.currentPlayer;
    final (status, winLine) = evaluateMove(newBoard, _state.currentPlayer);

    final newScoreX = status == GameStatus.xWins ? _state.scoreX + 1 : _state.scoreX;
    final newScoreO = status == GameStatus.oWins ? _state.scoreO + 1 : _state.scoreO;
    final next = _state.currentPlayer == CellValue.x ? CellValue.o : CellValue.x;

    _state = GameState(
      board: newBoard,
      currentPlayer: next,
      status: status,
      winLine: winLine,
      scoreX: newScoreX,
      scoreO: newScoreO,
    );
    notifyListeners();
    SoundService.instance.playMove();
    if (status != GameStatus.playing) {
      Future.delayed(const Duration(milliseconds: 400), SoundService.instance.playWin);
    }

    if (status == GameStatus.playing && !isMyTurn) {
      Timer(const Duration(milliseconds: 600), _doAiMove);
    }
  }

  void _doAiMove() {
    if (_state.status != GameStatus.playing) return;
    final move = AiService.getBestMove(_state.board, difficulty);
    if (move >= 0) makeMove(move);
  }

  @override
  void reset() {
    _state = GameState(
      board: List.filled(9, CellValue.empty),
      currentPlayer: CellValue.x,
      status: GameStatus.playing,
      winLine: null,
      scoreX: _state.scoreX,
      scoreO: _state.scoreO,
    );
    notifyListeners();
  }
}
