import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/remote_game_controller.dart';
import '../game/tictactoe_game.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/game_model.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import 'game_screen.dart'
    show GameBody, buildSharedAppBar; // ignore: unused_import

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
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(
          l10n.opponentLeft,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.opponentDisconnected,
          style: const TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(l10n.backToMenu),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(
          l10n.leaveGame,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.leaveGameWarning,
          style: const TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.stay),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.leave,
              style: const TextStyle(color: Colors.redAccent),
            ),
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
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: buildSharedAppBar(context, () async {
          final should = await _onWillPop();
          if (should && context.mounted) Navigator.pop(context);
        }),
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.canvasGradient),
          child: SafeArea(
            child: GameBody(
              controller: _controller,
              game: _game,
              onTap: _handleTap,
            ),
          ),
        ),
      ),
    );
  }
}
