import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import '../models/game_model.dart';
import '../models/user_profile.dart';

class RoomService {
  static final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ── Generate random 6-char alphanumeric code ────────────────────────────
  static String generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(6, (_) => chars[Random().nextInt(chars.length)]).join();
  }

  // ── Create room (creator = Player X) ────────────────────────────────────
  static Future<String> createRoom({
    GameType gameType = GameType.ticTacToe,
    UserProfile? profile,
  }) async {
    final code = generateCode();
    final boardSize = gameType == GameType.connectFour ? 42 : 9;
    await _db.child('rooms/$code').set({
      'board': List.filled(boardSize, 'empty'),
      'currentPlayer': 'x',
      'status': 'waiting',
      'winLine': null,
      'scoreX': 0,
      'scoreO': 0,
      'gameType': gameType.name,
      'createdAt': ServerValue.timestamp,
      if (profile != null)
        'player1': {
          'username': profile.username,
          'avatarSeed': profile.avatarSeed,
          if (profile.shareableImageUrl != null) 'customImageUrl': profile.shareableImageUrl,
        },
    });
    return code;
  }

  // ── Join room: only reads — does NOT change Firebase state yet ───────────
  // Call confirmJoin() after validating the game type on the client side.
  static Future<(JoinResult, GameType?)> joinRoom(String code) async {
    final snap = await _db.child('rooms/${code.toUpperCase()}').get();
    if (!snap.exists) return (JoinResult.notFound, null);

    final data = Map<String, dynamic>.from(snap.value as Map);
    if (data['status'] != 'waiting') return (JoinResult.roomFull, null);

    final gameType = data['gameType'] == 'connectFour'
        ? GameType.connectFour
        : GameType.ticTacToe;

    return (JoinResult.ok, gameType);
  }

  // ── Confirm join: sets status to 'playing' and saves player2 info ────────
  static Future<void> confirmJoin(String code, {UserProfile? profile}) {
    final updates = <String, dynamic>{'status': 'playing'};
    if (profile != null) {
      updates['player2'] = {
        'username': profile.username,
        'avatarSeed': profile.avatarSeed,
        if (profile.shareableImageUrl != null) 'customImageUrl': profile.shareableImageUrl,
      };
    }
    return _db.child('rooms/${code.toUpperCase()}').update(updates);
  }

  // ── Stream room state ─────────────────────────────────────────────────────
  static Stream<DatabaseEvent> watchRoom(String code) =>
      _db.child('rooms/$code').onValue;

  // ── Delete room ───────────────────────────────────────────────────────────
  static Future<void> deleteRoom(String code) =>
      _db.child('rooms/$code').remove();

  // ── Parse Firebase snapshot to GameState ──────────────────────────────────
  static GameState parseState(DataSnapshot snap) {
    final data = Map<String, dynamic>.from(snap.value as Map);

    final boardRaw = (data['board'] as List).map((e) => e.toString()).toList();
    final board = boardRaw.map((s) => switch (s) {
          'x' => CellValue.x,
          'o' => CellValue.o,
          _ => CellValue.empty,
        }).toList();

    final currentPlayer =
        data['currentPlayer'] == 'o' ? CellValue.o : CellValue.x;

    final status = switch (data['status'].toString()) {
      'xWins' => GameStatus.xWins,
      'oWins' => GameStatus.oWins,
      'draw' => GameStatus.draw,
      _ => GameStatus.playing,
    };

    List<int>? winLine;
    if (data['winLine'] != null) {
      winLine = (data['winLine'] as List).map((e) => int.parse(e.toString())).toList();
    }

    return GameState(
      board: board,
      currentPlayer: currentPlayer,
      status: status,
      winLine: winLine,
      scoreX: (data['scoreX'] as int?) ?? 0,
      scoreO: (data['scoreO'] as int?) ?? 0,
    );
  }
}

enum JoinResult { ok, notFound, roomFull }
