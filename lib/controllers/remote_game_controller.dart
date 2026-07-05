import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import '../models/game_model.dart';
import '../models/match_record.dart';
import '../models/user_profile.dart';
import '../services/history_service.dart';
import '../services/room_service.dart';
import '../services/sound_service.dart';
import '../utils/game_logic.dart';
import 'base_controller.dart';

class RemoteGameController extends BaseGameController {
  final String roomCode;
  final CellValue myRole;
  final void Function()? onOpponentLeft;

  late final DatabaseReference _roomRef;
  StreamSubscription<DatabaseEvent>? _sub;

  String? _player1Name;
  String? _player2Name;
  String? _player1AvatarSeed;
  String? _player2AvatarSeed;

  GameState _state = GameState(
    board: List.filled(9, CellValue.empty),
    currentPlayer: CellValue.x,
    status: GameStatus.playing,
    scoreX: 0,
    scoreO: 0,
  );

  RemoteGameController({
    required this.roomCode,
    required this.myRole,
    UserProfile? myProfile,
    this.onOpponentLeft,
  }) {
    if (myRole == CellValue.x) {
      _player1Name = myProfile?.username;
      _player1AvatarSeed = myProfile?.avatarSeed;
    } else {
      _player2Name = myProfile?.username;
      _player2AvatarSeed = myProfile?.avatarSeed;
    }
    _roomRef = FirebaseDatabase.instance.ref('rooms/$roomCode');
    _listenToRoom();
  }

  @override
  GameState get state => _state;

  @override
  PlayerLabel get player1Label =>
      myRole == CellValue.x ? PlayerLabel.player1 : PlayerLabel.opponent;

  @override
  PlayerLabel get player2Label =>
      myRole == CellValue.o ? PlayerLabel.player2 : PlayerLabel.opponent;

  @override
  String? get player1Name => _player1Name;

  @override
  String? get player2Name => _player2Name;

  @override
  String? get player1AvatarSeed => _player1AvatarSeed;

  @override
  String? get player2AvatarSeed => _player2AvatarSeed;

  @override
  bool get isMyTurn =>
      _state.currentPlayer == myRole && _state.status == GameStatus.playing;

  @override
  TurnMessage get turnMessage {
    if (_state.status != GameStatus.playing) return TurnMessage.none;
    return _state.currentPlayer == myRole
        ? TurnMessage.yourTurn
        : TurnMessage.opponentTurn;
  }

  void _listenToRoom() {
    _sub = _roomRef.onValue.listen((event) {
      if (!event.snapshot.exists) {
        onOpponentLeft?.call();
        return;
      }
      try {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        _parsePlayerInfo(data);
        final prevStatus = _state.status;
        final prevFilled = _state.board.where((c) => c != CellValue.empty).length;
        _state = RoomService.parseState(event.snapshot);
        final newFilled = _state.board.where((c) => c != CellValue.empty).length;
        notifyListeners();
        if (newFilled > prevFilled) SoundService.instance.playMove();
        if (_state.status != GameStatus.playing && prevStatus == GameStatus.playing) {
          Future.delayed(const Duration(milliseconds: 400), SoundService.instance.playWin);
          _recordResult();
        }
      } catch (_) {}
    });
  }

  void _recordResult() {
    HistoryService.instance.add(MatchRecord(
      gameType: GameType.ticTacToe,
      result: switch (_state.status) {
        GameStatus.draw => MatchResult.draw,
        GameStatus.xWins =>
          myRole == CellValue.x ? MatchResult.win : MatchResult.loss,
        _ => myRole == CellValue.o ? MatchResult.win : MatchResult.loss,
      },
      online: true,
      opponentName: myRole == CellValue.x ? _player2Name : _player1Name,
      playedAt: DateTime.now(),
    ));
  }

  void _parsePlayerInfo(Map<String, dynamic> data) {
    final p1 = data['player1'] as Map?;
    final p2 = data['player2'] as Map?;
    if (p1 != null) {
      final name = p1['username'] as String?;
      if (name != null && name.isNotEmpty) _player1Name = name;
      _player1AvatarSeed = p1['avatarSeed'] as String?;
    }
    if (p2 != null) {
      final name = p2['username'] as String?;
      if (name != null && name.isNotEmpty) _player2Name = name;
      _player2AvatarSeed = p2['avatarSeed'] as String?;
    }
  }

  @override
  void makeMove(int index) {
    if (!isMyTurn) return;
    if (_state.board[index] != CellValue.empty) return;

    final newBoard = List<CellValue>.from(_state.board)..[index] = myRole;
    final (status, winLine) = evaluateMove(newBoard, myRole);
    final scoreX = status == GameStatus.xWins ? _state.scoreX + 1 : _state.scoreX;
    final scoreO = status == GameStatus.oWins ? _state.scoreO + 1 : _state.scoreO;
    final next = myRole == CellValue.x ? CellValue.o : CellValue.x;

    _roomRef.update({
      'board': newBoard.map((c) => c.name).toList(),
      'currentPlayer': (status == GameStatus.playing ? next : myRole).name,
      'status': status.name,
      'winLine': winLine,
      'scoreX': scoreX,
      'scoreO': scoreO,
    });
  }

  @override
  void reset() {
    _roomRef.update({
      'board': List.filled(9, CellValue.empty.name),
      'currentPlayer': (Random().nextBool() ? CellValue.x : CellValue.o).name,
      'status': GameStatus.playing.name,
      'winLine': null,
    });
  }

  Future<void> leaveRoom() async {
    await _sub?.cancel();
    await RoomService.deleteRoom(roomCode);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
