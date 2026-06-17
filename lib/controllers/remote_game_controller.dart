import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/game_model.dart';
import '../models/user_profile.dart';
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

  String _player1Name;
  String _player2Name;
  String? _player1AvatarSeed;
  String? _player2AvatarSeed;
  String? _player1CustomImagePath;
  String? _player2CustomImagePath;

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
  })  : _player1Name = myRole == CellValue.x
            ? (myProfile?.username ?? 'Player 1')
            : 'Opponent',
        _player2Name = myRole == CellValue.o
            ? (myProfile?.username ?? 'Player 2')
            : 'Opponent',
        _player1AvatarSeed =
            myRole == CellValue.x ? myProfile?.avatarSeed : null,
        _player2AvatarSeed =
            myRole == CellValue.o ? myProfile?.avatarSeed : null,
        _player1CustomImagePath =
            myRole == CellValue.x ? myProfile?.customImagePath : null,
        _player2CustomImagePath =
            myRole == CellValue.o ? myProfile?.customImagePath : null {
    _roomRef = FirebaseDatabase.instance.ref('rooms/$roomCode');
    _listenToRoom();
  }

  @override
  GameState get state => _state;

  @override
  String get player1Label => _player1Name;

  @override
  String get player2Label => _player2Name;

  @override
  String? get player1AvatarSeed => _player1AvatarSeed;

  @override
  String? get player2AvatarSeed => _player2AvatarSeed;

  @override
  String? get player1CustomImagePath => _player1CustomImagePath;

  @override
  String? get player2CustomImagePath => _player2CustomImagePath;

  @override
  bool get isMyTurn =>
      _state.currentPlayer == myRole && _state.status == GameStatus.playing;

  @override
  String get turnMessage {
    if (_state.status != GameStatus.playing) return '';
    return _state.currentPlayer == myRole ? 'Your turn!' : 'Opponent\'s turn...';
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
        }
      } catch (_) {}
    });
  }

  void _parsePlayerInfo(Map<String, dynamic> data) {
    final p1 = data['player1'] as Map?;
    final p2 = data['player2'] as Map?;
    if (p1 != null) {
      final name = p1['username'] as String?;
      if (name != null && name.isNotEmpty) _player1Name = name;
      _player1AvatarSeed = p1['avatarSeed'] as String?;
      _player1CustomImagePath = p1['customImageUrl'] as String?;
    }
    if (p2 != null) {
      final name = p2['username'] as String?;
      if (name != null && name.isNotEmpty) _player2Name = name;
      _player2AvatarSeed = p2['avatarSeed'] as String?;
      _player2CustomImagePath = p2['customImageUrl'] as String?;
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
      'currentPlayer': CellValue.x.name,
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
