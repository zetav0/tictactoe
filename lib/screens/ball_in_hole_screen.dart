import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/ball_in_hole_game.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/ball_level.dart';
import '../models/game_model.dart';
import '../models/match_record.dart';
import '../services/ball_progress_service.dart';
import '../services/history_service.dart';
import '../theme/app_colors.dart';
import '../theme/playful_theme.dart';
import '../widgets/tappable.dart';

/// Formats a play time as m:ss.t (tenths).
String formatBallTime(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;
  final tenths = (d.inMilliseconds % 1000) ~/ 100;
  return '$minutes:${seconds.toString().padLeft(2, '0')}.$tenths';
}

class BallInHoleScreen extends StatefulWidget {
  /// 0-based index into [BallLevel.all].
  final int levelIndex;

  const BallInHoleScreen({super.key, required this.levelIndex});

  @override
  State<BallInHoleScreen> createState() => _BallInHoleScreenState();
}

class _BallInHoleScreenState extends State<BallInHoleScreen> {
  late int _levelIndex;
  late BallInHoleGame _game;
  Timer? _overlayTimer;
  bool _overlayVisible = false;
  Duration _winTime = Duration.zero;
  bool _newBest = false;

  bool get _isLastLevel => _levelIndex + 1 >= BallLevel.count;

  @override
  void initState() {
    super.initState();
    _levelIndex = widget.levelIndex;
    _createGame();
  }

  void _createGame() {
    _game = BallInHoleGame(
      level: BallLevel.all[_levelIndex],
      onWin: _handleWin,
    );
  }

  Future<void> _handleWin(Duration elapsed) async {
    final level = _levelIndex + 1;
    final newBest = await BallProgressService.instance.recordCompletion(
      level,
      elapsed,
    );
    await HistoryService.instance.add(
      MatchRecord(
        gameType: GameType.ballInHole,
        result: MatchResult.win,
        online: false,
        level: level,
        playedAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    _winTime = elapsed;
    _newBest = newBest;
    _overlayTimer?.cancel();
    // A short breath after the sink animation before the modal pops in.
    _overlayTimer = Timer(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _overlayVisible = true);
    });
  }

  void _restart() {
    _overlayTimer?.cancel();
    if (_overlayVisible) setState(() => _overlayVisible = false);
    _game.resetLevel();
  }

  void _nextLevel() {
    _overlayTimer?.cancel();
    setState(() {
      _levelIndex++;
      _overlayVisible = false;
      _createGame();
    });
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(l10n),
      body: Stack(
        children: [
          const Positioned(
            top: 60,
            left: -40,
            child: _Blob(color: AppColors.primaryContainer, size: 160),
          ),
          const Positioned(
            bottom: 140,
            right: -50,
            child: _Blob(color: AppColors.secondary, size: 200),
          ),
          SafeArea(
            child: Column(
              children: [
                _Hud(game: _game, levelNumber: _levelIndex + 1),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (d) => _game.dragStart(d.localPosition),
                    onPanUpdate: (d) => _game.dragUpdate(d.localPosition),
                    onPanEnd: (_) => _game.dragEnd(),
                    onPanCancel: _game.dragEnd,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: AspectRatio(
                            aspectRatio: _game.level.aspectRatio,
                            child: Container(
                              decoration: PlayfulTheme.boardDecoration(),
                              padding: const EdgeInsets.all(8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: GameWidget(
                                  key: ObjectKey(_game),
                                  game: _game,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _HintText(game: _game),
                _RestartButton(onPressed: _restart),
                const SizedBox(height: 8),
              ],
            ),
          ),
          if (_overlayVisible)
            _LevelCompleteOverlay(
              title: _isLastLevel
                  ? l10n.allLevelsComplete
                  : l10n.levelComplete,
              time: _winTime,
              newBest: _newBest,
              onNext: _isLastLevel ? null : _nextLevel,
              onReplay: _restart,
              onHome: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        l10n.gameBallInHole.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: AppColors.secondary,
        ),
      ),
      centerTitle: true,
    );
  }
}

// ── HUD: level, timer, falls ─────────────────────────────────────────────────

class _Hud extends StatelessWidget {
  final BallInHoleGame game;
  final int levelNumber;

  const _Hud({required this.game, required this.levelNumber});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          _HudChip(
            child: Text(
              l10n.levelN(levelNumber),
              style: _chipStyle(AppColors.secondary),
            ),
          ),
          const Spacer(),
          _HudChip(
            child: ValueListenableBuilder<Duration>(
              valueListenable: game.elapsed,
              builder: (context, elapsed, _) => Text(
                formatBallTime(elapsed),
                style: _chipStyle(Colors.white).copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          const Spacer(),
          _HudChip(
            child: ValueListenableBuilder<int>(
              valueListenable: game.falls,
              builder: (context, falls, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: falls > 0
                        ? const Color(0xFFFF6B6B)
                        : Colors.white38,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$falls',
                    style: _chipStyle(
                      falls > 0 ? Colors.white : Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _chipStyle(Color color) => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: color,
  );
}

class _HudChip extends StatelessWidget {
  final Widget child;

  const _HudChip({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: child,
    );
  }
}

// ── Input hint ───────────────────────────────────────────────────────────────

class _HintText extends StatelessWidget {
  final BallInHoleGame game;

  const _HintText({required this.game});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: game.hasSensor,
      builder: (context, hasSensor, _) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          hasSensor ? l10n.bihHintTilt : l10n.bihHintDrag,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white38,
          ),
        ),
      ),
    );
  }
}

// ── Atmospheric blur blob (same look as the other game screens) ─────────────

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

// ── Restart button ───────────────────────────────────────────────────────────

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
              const Icon(
                Icons.refresh_rounded,
                color: AppColors.onTertiary,
                size: 22,
              ),
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

// ── Level complete overlay ───────────────────────────────────────────────────

class _LevelCompleteOverlay extends StatelessWidget {
  final String title;
  final Duration time;
  final bool newBest;
  final VoidCallback? onNext;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const _LevelCompleteOverlay({
    required this.title,
    required this.time,
    required this.newBest,
    required this.onNext,
    required this.onReplay,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child:
              Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.tertiary.withValues(alpha: 0.4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tertiary.withValues(alpha: 0.3),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⛳', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.tertiary,
                            shadows: PlayfulTheme.bubbleShadow(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatBallTime(time),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (newBest) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              l10n.newBestTime,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSecondary,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 26),
                        if (onNext != null) ...[
                          _OverlayButton(
                            label: l10n.nextLevel,
                            color: AppColors.secondary,
                            textColor: AppColors.onSecondary,
                            shadowColor: AppColors.secondaryContainer,
                            onTap: onNext!,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _OverlayButton(
                          label: l10n.playAgain,
                          color: Colors.white.withValues(alpha: 0.15),
                          textColor: Colors.white,
                          onTap: onReplay,
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
                  .scaleXY(
                    begin: 0.82,
                    curve: Curves.easeOutBack,
                    duration: 380.ms,
                  )
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
