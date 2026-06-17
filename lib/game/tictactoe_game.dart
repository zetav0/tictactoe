import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../controllers/base_controller.dart';
import 'components/board_component.dart';

class TicTacToeGame extends FlameGame {
  final BaseGameController controller;
  late BoardComponent _board;

  TicTacToeGame({required this.controller});

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    _board = BoardComponent(controller: controller);
    add(_board);
    controller.addListener(_onStateChanged);
  }

  @override
  void onDetach() {
    controller.removeListener(_onStateChanged);
    super.onDetach();
  }

  int? getCellIndex(Vector2 pos) => _board.getCellIndex(pos);

  void _onStateChanged() {
    _board.syncState(controller.state);
  }
}
