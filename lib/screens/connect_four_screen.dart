import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/base_controller.dart';
import '../controllers/connect_four_controller.dart';
import '../models/game_model.dart';
import '../theme/app_colors.dart';
import '../utils/connect_four_logic.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/connect_four_board.dart';
import '../widgets/score_card.dart';
import '../widgets/tappable.dart';
import '../widgets/turn_indicator.dart';

class ConnectFourScreen extends StatefulWidget {
  final GameMode mode;
  final AIDifficulty difficulty;

  const ConnectFourScreen({
    super.key,
    required this.mode,
    required this.difficulty,
  });

  @override
  State<ConnectFourScreen> createState() => _ConnectFourScreenState();
}

class _ConnectFourScreenState extends State<ConnectFourScreen> {
  late final ConnectFourController _controller;
  Timer? _overlayTimer;
  bool _overlayVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = ConnectFourController(
      mode: widget.mode,
      difficulty: widget.difficulty,
    );
    _controller.addListener(_onStateChange);
  }

  void _onStateChange() {
    final status = _controller.state.status;
    if (status != GameStatus.playing) {
      _overlayTimer?.cancel();
      // Delay = staggered win animation (4 cells × 160ms + 450ms bounce + 800ms pulse)
      _overlayTimer = Timer(const Duration(milliseconds: 2200), () {
        if (mounted) setState(() => _overlayVisible = true);
      });
    } else {
      _overlayTimer?.cancel();
      if (_overlayVisible) setState(() => _overlayVisible = false);
    }
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    _controller.removeListener(_onStateChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              ScoreCards(controller: _controller),
              TurnIndicator(controller: _controller),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: AspectRatio(
                        aspectRatio: c4Cols / c4Rows,
                        child: ConnectFourBoard(controller: _controller),
                      ),
                    ),
                  ),
                ),
              ),
              _RestartButton(onPressed: _controller.reset),
              const SizedBox(height: 8),
            ],
          ),
          if (_overlayVisible && _controller.state.status != GameStatus.playing)
            C4GameOverOverlay(
              controller: _controller,
              onRestart: () {
                setState(() => _overlayVisible = false);
                _controller.reset();
              },
              onHome: () => Navigator.pop(context),
            ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryFixedDim),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        '4 EN RAYA',
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
}

// ── Restart Button ─────────────────────────────────────────────────────────────

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
        ),
      ),
    );
  }
}

// ── Game Over Overlay (shared with remote screen) ──────────────────────────────

class C4GameOverOverlay extends StatelessWidget {
  final BaseGameController controller;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const C4GameOverOverlay({
    super.key,
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
