import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/base_controller.dart';
import '../controllers/game_controller.dart';
import '../game/tictactoe_game.dart';
import '../l10n/gen/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/game_model.dart';
import '../theme/app_colors.dart';
import '../theme/playful_theme.dart';
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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: buildSharedAppBar(context, () => Navigator.pop(context)),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.canvasGradient),
        child: SafeArea(
          child: GameBody(controller: _controller, game: _game, onTap: _handleTap),
        ),
      ),
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
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            color: AppColors.tertiary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: PlayfulTheme.tertiaryLip(depth: 5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.refresh_rounded, color: AppColors.onTertiary, size: 22),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).restartGame,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onTertiary,
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
    final l10n = AppLocalizations.of(context);
    final state = controller.state;
    final (String title, String emoji, Color accentColor) = switch (state.status) {
      GameStatus.xWins => (
          l10n.playerWins(playerDisplayName(
              l10n, controller.player1Label, controller.player1Name)),
          '🎉',
          AppColors.xColor,
        ),
      GameStatus.oWins => (
          l10n.playerWins(playerDisplayName(
              l10n, controller.player2Label, controller.player2Name)),
          '🎉',
          AppColors.oColor,
        ),
      GameStatus.draw => (l10n.itsADraw, '🤝', Colors.white70),
      GameStatus.playing => ('', '', Colors.transparent),
    };

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.35),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: PlayfulTheme.bubbleShadow(),
                  ),
                ),
                const SizedBox(height: 28),
                _OverlayButton(
                  label: l10n.playAgain,
                  color: AppColors.secondary,
                  textColor: AppColors.onSecondary,
                  shadowColor: AppColors.secondaryContainer,
                  onTap: onRestart,
                ),
                const SizedBox(height: 12),
                _OverlayButton(
                  label: l10n.home,
                  color: Colors.white.withValues(alpha: 0.15),
                  textColor: Colors.white,
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
  final Color? shadowColor;
  final VoidCallback onTap;

  const _OverlayButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor = Colors.white,
    this.shadowColor,
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
          padding: EdgeInsets.only(
            top: 16,
            bottom: _pressed ? 16 : (widget.shadowColor != null ? 12 : 16),
          ),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.shadowColor != null && !_pressed
                ? PlayfulTheme.lipShadow(widget.shadowColor!, depth: 4)
                : null,
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}

AppBar buildSharedAppBar(BuildContext context, VoidCallback onBack,
    {String? title}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
      onPressed: onBack,
    ),
    title: Text(
      title ?? AppLocalizations.of(context).gameTicTacToe.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
        color: Colors.white,
      ),
    ),
    centerTitle: true,
    actions: [
      IconButton(
        icon: const Icon(Icons.leaderboard_rounded, color: Colors.white70),
        onPressed: () {},
      ),
    ],
  );
}
