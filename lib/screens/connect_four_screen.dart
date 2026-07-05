import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/base_controller.dart';
import '../controllers/connect_four_controller.dart';
import '../l10n/gen/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/game_model.dart';
import '../theme/app_colors.dart';
import '../theme/playful_theme.dart';
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
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Decorative atmospheric blobs
          Positioned(
            top: 60, left: -40,
            child: _Blob(color: AppColors.primaryContainer, size: 160),
          ),
          Positioned(
            bottom: 140, right: -50,
            child: _Blob(color: AppColors.secondary, size: 200),
          ),
          SafeArea(
            child: Column(
              children: [
                ScoreCards(controller: _controller, glassStyle: false),
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppLocalizations.of(context).gameConnectFour.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: AppColors.secondary, // Yellow accent — matches stitch
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
}

// ── Atmospheric blur blob ─────────────────────────────────────────────────────

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
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
            color: AppColors.tertiary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: PlayfulTheme.tertiaryLip(depth: 4),
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
        ),
      ),
    );
  }
}

// ── Game Over Overlay ──────────────────────────────────────────────────────────

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
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: accentColor.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
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
                    color: accentColor,
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
