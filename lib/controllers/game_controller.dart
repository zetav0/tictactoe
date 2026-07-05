import 'dart:async';
import 'dart:math';
import '../models/game_model.dart';
import '../models/match_record.dart';
import '../services/ai_service.dart';
import '../services/history_service.dart';
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
      Timer(const Duration(milliseconds: 600), _doAiMove);
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
      HistoryService.instance.add(MatchRecord(
        gameType: GameType.ticTacToe,
        result: switch (status) {
          GameStatus.xWins => MatchResult.win,
          GameStatus.oWins => MatchResult.loss,
          _ => MatchResult.draw,
        },
        online: false,
        difficulty: mode == GameMode.pvAi ? difficulty : null,
        playedAt: DateTime.now(),
      ));
    }

    _scheduleAiMoveIfNeeded();
  }

  void _doAiMove() {
    // isMyTurn guards against a reset landing between the trigger and now.
    if (_state.status != GameStatus.playing || isMyTurn) return;
    final move = AiService.getBestMove(_state.board, difficulty);
    if (move >= 0) makeMove(move);
  }

  @override
  void reset() {
    _state = GameState(
      board: List.filled(9, CellValue.empty),
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
