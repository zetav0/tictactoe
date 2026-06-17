import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/remote_game_controller.dart';
import '../game/tictactoe_game.dart';
import '../models/game_model.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';
import 'game_screen.dart' show GameBody, buildSharedAppBar; // ignore: unused_import

class RemoteGameScreen extends ConsumerStatefulWidget {
  final String roomCode;
  final CellValue myRole;

  const RemoteGameScreen({
    super.key,
    required this.roomCode,
    required this.myRole,
  });

  @override
  ConsumerState<RemoteGameScreen> createState() => _RemoteGameScreenState();
}

class _RemoteGameScreenState extends ConsumerState<RemoteGameScreen> {
  late final RemoteGameController _controller;
  late final TicTacToeGame _game;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).valueOrNull;
    _controller = RemoteGameController(
      roomCode: widget.roomCode,
      myRole: widget.myRole,
      myProfile: profile,
      onOpponentLeft: _onOpponentLeft,
    );
    _game = TicTacToeGame(controller: _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onOpponentLeft() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Text('Opponent left', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your opponent disconnected.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Menu'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Text('Leave game?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'The room will be deleted for both players.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.leaveRoom();
      return true;
    }
    return false;
  }

  void _handleTap(TapDownDetails details) {
    if (!_controller.isMyTurn) return;
    if (_controller.state.status != GameStatus.playing) return;
    final pos = details.localPosition;
    final index = _game.getCellIndex(Vector2(pos.dx, pos.dy));
    if (index != null) _controller.makeMove(index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final should = await _onWillPop();
          if (should && context.mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: buildSharedAppBar(() async {
          final should = await _onWillPop();
          if (should && context.mounted) Navigator.pop(context);
        }),
        body: GameBody(controller: _controller, game: _game, onTap: _handleTap),
        bottomNavigationBar: const AppBottomNav(),
      ),
    );
  }
}
