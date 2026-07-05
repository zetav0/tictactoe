import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/controllers/connect_four_controller.dart';
import 'package:tictactoe/controllers/game_controller.dart';
import 'package:tictactoe/models/game_model.dart';

// P(all 40 samples land on the same starter) = 2^-39 — effectively zero.
void main() {
  test('tic tac toe PvP starting player is randomized', () {
    final starters = {
      for (var i = 0; i < 40; i++)
        GameController(mode: GameMode.pvp, difficulty: AIDifficulty.easy)
            .state
            .currentPlayer,
    };
    expect(starters, containsAll([CellValue.x, CellValue.o]));
  });

  test('connect four PvP starting player is randomized', () {
    final starters = {
      for (var i = 0; i < 40; i++)
        ConnectFourController(mode: GameMode.pvp, difficulty: AIDifficulty.easy)
            .state
            .currentPlayer,
    };
    expect(starters, containsAll([CellValue.x, CellValue.o]));
  });
}
