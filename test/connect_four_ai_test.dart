import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/models/game_model.dart';
import 'package:tictactoe/services/connect_four_ai.dart';
import 'package:tictactoe/utils/connect_four_logic.dart';

List<CellValue> emptyBoard() =>
    List.filled(c4Rows * c4Cols, CellValue.empty);

/// Drops [p] into [col] exactly like the game does (gravity).
void drop(List<CellValue> b, int col, CellValue p) {
  final row = c4DropRow(b, col);
  b[row * c4Cols + col] = p;
}

// The AI always plays O; X (the human) moves first, so in every position
// where it is O's turn: count(X) == count(O) + 1.
void main() {
  test('hard AI takes an immediate win', () async {
    final b = emptyBoard();
    // Bottom row: O O O _ ... → O wins by playing column 3.
    drop(b, 0, CellValue.o);
    drop(b, 1, CellValue.o);
    drop(b, 2, CellValue.o);
    drop(b, 0, CellValue.x);
    drop(b, 1, CellValue.x);
    drop(b, 6, CellValue.x);
    drop(b, 6, CellValue.x);
    final col = await ConnectFourAI.getBestColumn(b, AIDifficulty.hard);
    expect(col, 3);
  });

  test('hard AI blocks an immediate loss', () async {
    final b = emptyBoard();
    // Bottom row: X X X _ ... → O must block column 3.
    drop(b, 0, CellValue.x);
    drop(b, 1, CellValue.x);
    drop(b, 2, CellValue.x);
    drop(b, 0, CellValue.o);
    drop(b, 1, CellValue.o);
    final col = await ConnectFourAI.getBestColumn(b, AIDifficulty.hard);
    expect(col, 3);
  });

  test('hard AI finds the double-threat forced win', () async {
    final b = emptyBoard();
    // Bottom row: X _ O O _ _ X (plus X stacked on col 6).
    // Only column 4 creates the open-ended O O O with threats at 1 and 5;
    // column 1 or 5 gives a single threat that X simply blocks.
    drop(b, 0, CellValue.x);
    drop(b, 2, CellValue.o);
    drop(b, 3, CellValue.o);
    drop(b, 6, CellValue.x);
    drop(b, 6, CellValue.x);
    final col = await ConnectFourAI.getBestColumn(b, AIDifficulty.hard);
    expect(col, 4);
  });

  test('medium AI still blocks an immediate loss', () async {
    final b = emptyBoard();
    drop(b, 0, CellValue.x);
    drop(b, 1, CellValue.x);
    drop(b, 2, CellValue.x);
    drop(b, 0, CellValue.o);
    drop(b, 1, CellValue.o);
    final col = await ConnectFourAI.getBestColumn(b, AIDifficulty.medium);
    expect(col, 3);
  });
}
