import 'game_model.dart';

enum MatchResult { win, loss, draw }

/// One finished match, stored in the local history.
///
/// [result] is from the local player's perspective: player 1 in local games,
/// the own role in online games.
class MatchRecord {
  final GameType gameType;
  final MatchResult result;
  final bool online;
  final AIDifficulty? difficulty; // set only for games against the AI
  final String? opponentName; // online opponent's username, when known
  final DateTime playedAt;

  const MatchRecord({
    required this.gameType,
    required this.result,
    required this.online,
    this.difficulty,
    this.opponentName,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() => {
    'gameType': gameType.name,
    'result': result.name,
    'online': online,
    if (difficulty != null) 'difficulty': difficulty!.name,
    if (opponentName != null) 'opponentName': opponentName,
    'playedAt': playedAt.millisecondsSinceEpoch,
  };

  static MatchRecord? tryParse(dynamic json) {
    try {
      final map = Map<String, dynamic>.from(json as Map);
      return MatchRecord(
        gameType: GameType.values.byName(map['gameType'] as String),
        result: MatchResult.values.byName(map['result'] as String),
        online: map['online'] as bool? ?? false,
        difficulty: map['difficulty'] != null
            ? AIDifficulty.values.byName(map['difficulty'] as String)
            : null,
        opponentName: map['opponentName'] as String?,
        playedAt: DateTime.fromMillisecondsSinceEpoch(
          map['playedAt'] as int? ?? 0,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
