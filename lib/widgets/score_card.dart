import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multiavatar/multiavatar.dart';
import '../controllers/base_controller.dart';
import '../l10n/gen/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/game_model.dart';
import '../theme/app_colors.dart';

class ScoreCards extends StatelessWidget {
  final BaseGameController controller;

  /// When true (default, tic-tac-toe on gradient bg): glass-style white panels.
  /// When false (connect-four on dark bg): dark #1E2020 panels with 3D bevel.
  final bool glassStyle;

  const ScoreCards({super.key, required this.controller, this.glassStyle = true});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        final p1Active = state.currentPlayer == CellValue.x &&
            state.status == GameStatus.playing;
        final p2Active = state.currentPlayer == CellValue.o &&
            state.status == GameStatus.playing;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              _Card(
                label: playerDisplayName(
                    l10n, controller.player1Label, controller.player1Name),
                avatarSeed: controller.player1AvatarSeed,
                score: state.scoreX,
                active: p1Active,
                color: AppColors.xColor,
                avatarBg: AppColors.primaryContainer,
                glassStyle: glassStyle,
              ),
              const SizedBox(width: 16),
              _Card(
                label: playerDisplayName(
                    l10n, controller.player2Label, controller.player2Name),
                avatarSeed: controller.player2AvatarSeed,
                score: state.scoreO,
                active: p2Active,
                color: AppColors.oColor,
                avatarBg: AppColors.secondaryContainer,
                glassStyle: glassStyle,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  final String label;
  final String? avatarSeed;
  final int score;
  final bool active;
  final Color color;
  final Color avatarBg;
  final bool glassStyle;

  const _Card({
    required this.label,
    required this.score,
    required this.active,
    required this.color,
    this.avatarSeed,
    this.avatarBg = AppColors.primaryContainer,
    this.glassStyle = true,
  });

  BoxDecoration _darkDecoration(bool active) => BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: active ? color.withValues(alpha: 0.5) : AppColors.outlineVariant,
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      );

  BoxDecoration _glassDecoration(bool active) => BoxDecoration(
        color: active
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? color.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.2),
          width: active ? 2 : 1,
        ),
        boxShadow: active
            ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 20)]
            : null,
      );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: glassStyle ? _glassDecoration(active) : _darkDecoration(active),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatarSeed != null) ...[
              _Avatar(
                seed: avatarSeed!,
                active: active,
                color: color,
                bg: glassStyle ? null : avatarBg,
              ),
              const SizedBox(height: 6),
            ],
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: avatarSeed != null ? 10 : 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: active ? Colors.white : Colors.white54,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: Tween<double>(begin: 0.4, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Text(
                '$score',
                key: ValueKey(score),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String seed;
  final bool active;
  final Color color;
  /// If non-null, fills the circle with this solid background color (dark-style cards).
  final Color? bg;

  const _Avatar({
    required this.seed,
    required this.active,
    required this.color,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(
          color: active ? color.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: active
            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12)]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: SvgPicture.string(multiavatar(seed), fit: BoxFit.cover),
    );
  }
}
