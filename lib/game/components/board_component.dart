import 'dart:ui';
import 'package:flame/components.dart';
import '../../controllers/base_controller.dart';
import '../../models/game_model.dart';
import '../../theme/app_colors.dart';
import 'cell_component.dart';
import 'win_line_component.dart';

class BoardComponent extends PositionComponent {
  final BaseGameController controller;

  final List<CellComponent> _cells = [];
  WinLineComponent? _winLine;

  static const double _kPad = 0.04;
  static const double _kGap = 0.03;

  BoardComponent({required this.controller});

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < 9; i++) {
      final cell = CellComponent(index: i);
      _cells.add(cell);
      add(cell);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _layoutCells();
  }

  void _layoutCells() {
    if (_cells.isEmpty) return;
    final s = size.x;
    final pad = s * _kPad;
    final gap = s * _kGap;
    final cellSize = (s - 2 * pad - 2 * gap) / 3;

    for (int i = 0; i < 9; i++) {
      _cells[i].size = Vector2.all(cellSize);
      _cells[i].position = Vector2(
        pad + (i % 3) * (cellSize + gap),
        pad + (i ~/ 3) * (cellSize + gap),
      );
    }
  }

  /// Returns the cell index at [pos] in board-local coordinates, or null.
  int? getCellIndex(Vector2 pos) {
    for (int i = 0; i < _cells.length; i++) {
      final c = _cells[i];
      if (pos.x >= c.position.x &&
          pos.x <= c.position.x + c.size.x &&
          pos.y >= c.position.y &&
          pos.y <= c.position.y + c.size.y) {
        return i;
      }
    }
    return null;
  }

  void syncState(GameState state) {
    for (int i = 0; i < 9; i++) {
      _cells[i].setValue(state.board[i]);
      _cells[i].setWin(state.winLine != null && state.winLine!.contains(i));
    }

    if (state.winLine != null && _winLine == null) {
      _addWinLine(state.winLine!);
    } else if (state.winLine == null && _winLine != null) {
      _winLine!.removeFromParent();
      _winLine = null;
    }
  }

  void _addWinLine(List<int> winLine) {
    final s = size.x;
    final pad = s * _kPad;
    final gap = s * _kGap;
    final cellSize = (s - 2 * pad - 2 * gap) / 3;

    Vector2 center(int idx) => Vector2(
          pad + (idx % 3) * (cellSize + gap) + cellSize / 2,
          pad + (idx ~/ 3) * (cellSize + gap) + cellSize / 2,
        );

    _winLine = WinLineComponent(
      start: center(winLine.first),
      end: center(winLine.last),
    )..priority = 10;
    add(_winLine!);
  }

  @override
  void render(Canvas canvas) {
    final pad = size.x * 0.01;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pad, pad, size.x - 2 * pad, size.y - 2 * pad),
      Radius.circular(size.x * 0.08),
    );
    canvas.drawRRect(rrect, Paint()..color = AppColors.surfaceContainer);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = AppColors.outlineVariant.withAlpha(40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}
