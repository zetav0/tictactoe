import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/base_controller.dart';
import '../controllers/game_controller.dart';
import '../game/tictactoe_game.dart';
import '../models/game_model.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/score_card.dart';
import '../widgets/tappable.dart';
import '../widgets/turn_indicator.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final AIDifficulty difficulty;

  const GameScreen({super.key, required this.mode, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _controller;
  late final TicTacToeGame _game;

  @override
  void initState() {
    super.initState();
    _controller = GameController(mode: widget.mode, difficulty: widget.difficulty);
    _game = TicTacToeGame(controller: _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildSharedAppBar(() => Navigator.pop(context)),
      body: GameBody(controller: _controller, game: _game, onTap: _handleTap),
      bottomNavigationBar: const AppBottomNav(),
    );
  }

}

// ── Shared body used by both local and remote game screens ─────────────────
class GameBody extends StatelessWidget {
  final BaseGameController controller;
  final TicTacToeGame game;
  final GestureTapDownCallback onTap;

  const GameBody({
    super.key,
    required this.controller,
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            ScoreCards(controller: controller),
            Center(child: TurnIndicator(controller: controller)),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: onTap,
                      child: GameWidget(game: game),
                    ),
                  ),
                ),
              ),
            ),
            _RestartButton(onPressed: controller.reset),
            const SizedBox(height: 8),
          ],
        ),
        _DelayedGameOverOverlay(controller: controller),
      ],
    );
  }
}

class _DelayedGameOverOverlay extends StatefulWidget {
  final BaseGameController controller;
  const _DelayedGameOverOverlay({required this.controller});

  @override
  State<_DelayedGameOverOverlay> createState() => _DelayedGameOverOverlayState();
}

class _DelayedGameOverOverlayState extends State<_DelayedGameOverOverlay> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChange);
  }

  void _onStateChange() {
    final status = widget.controller.state.status;
    if (status != GameStatus.playing) {
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _visible = true);
      });
    } else {
      _timer?.cancel();
      if (_visible) setState(() => _visible = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.controller.removeListener(_onStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible || widget.controller.state.status == GameStatus.playing) {
      return const SizedBox.shrink();
    }
    return _GameOverOverlay(
      controller: widget.controller,
      onRestart: widget.controller.reset,
      onHome: () => Navigator.pop(context),
    );
  }
}

class _RestartButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _RestartButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: TappableScale(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.refresh_rounded, color: AppColors.onPrimary),
              const SizedBox(width: 8),
              Text(
                'Restart Game',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        )
            .animate()
            .scaleXY(begin: 0.95, end: 1, duration: 150.ms, curve: Curves.easeOut),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final BaseGameController controller;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const _GameOverOverlay({
    required this.controller,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final (String title, String emoji, Color color) = switch (state.status) {
      GameStatus.xWins => (
          '${controller.player1Label} Wins!',
          '🎉',
          AppColors.primaryFixedDim,
        ),
      GameStatus.oWins => (
          '${controller.player2Label} Wins!',
          '🎉',
          AppColors.tertiaryFixed,
        ),
      GameStatus.draw => ("It's a Draw!", '🤝', Colors.white54),
      GameStatus.playing => ('', '', Colors.transparent),
    };

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: Colors.black.withAlpha(130),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer.withAlpha(230),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withAlpha(70)),
              boxShadow: [
                BoxShadow(color: color.withAlpha(50), blurRadius: 40),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 52)),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 28),
                _OverlayButton(
                  label: 'Play Again',
                  color: AppColors.primary,
                  onTap: onRestart,
                ),
                const SizedBox(height: 12),
                _OverlayButton(
                  label: 'Home',
                  color: AppColors.surfaceContainerHigh,
                  textColor: Colors.white60,
                  onTap: onHome,
                ),
              ],
            ),
          )
              .animate()
              .scaleXY(begin: 0.82, curve: Curves.easeOutBack, duration: 380.ms)
              .fadeIn(duration: 200.ms),
        ),
      ),
    );
  }
}

class _OverlayButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _OverlayButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor = Colors.white,
  });

  @override
  State<_OverlayButton> createState() => _OverlayButtonState();
}

class _OverlayButtonState extends State<_OverlayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}

AppBar buildSharedAppBar(VoidCallback onBack) {
  return AppBar(
    backgroundColor: AppColors.background,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryFixedDim),
      onPressed: onBack,
    ),
    title: Text(
      'TIC TAC TOE',
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: AppColors.primaryFixedDim,
      ),
    ),
    centerTitle: true,
    actions: [
      IconButton(
        icon: const Icon(Icons.leaderboard_rounded, color: AppColors.primaryFixedDim),
        onPressed: () {},
      ),
    ],
  );
}
