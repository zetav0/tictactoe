import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/models/game_model.dart';
import 'package:tictactoe/models/match_record.dart';
import 'package:tictactoe/services/history_service.dart';

void main() {
  test('records are added newest-first, capped at 50 and persisted', () async {
    SharedPreferences.setMockInitialValues({});
    final service = HistoryService.instance;
    await service.ensureLoaded();

    for (var i = 0; i < 55; i++) {
      await service.add(MatchRecord(
        gameType: GameType.ticTacToe,
        result: MatchResult.win,
        online: false,
        playedAt: DateTime.fromMillisecondsSinceEpoch(i * 1000),
      ));
    }

    expect(service.records.length, 50);
    expect(service.records.first.playedAt.millisecondsSinceEpoch, 54000);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('match_history'), isNotNull);
  });

  test('tryParse tolerates corrupt entries', () {
    expect(MatchRecord.tryParse({'garbage': true}), isNull);
    final record = MatchRecord.tryParse({
      'gameType': 'connectFour',
      'result': 'loss',
      'online': true,
      'opponentName': 'Nacho',
      'playedAt': 1000,
    });
    expect(record, isNotNull);
    expect(record!.gameType, GameType.connectFour);
    expect(record.opponentName, 'Nacho');
  });
}
