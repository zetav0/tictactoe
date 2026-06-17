import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multiavatar/multiavatar.dart';
import '../controllers/base_controller.dart';
import '../models/game_model.dart';
import '../theme/app_colors.dart';

class ScoreCards extends StatelessWidget {
  final BaseGameController controller;

  const ScoreCards({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
                label: controller.player1Label,
                avatarSeed: controller.player1AvatarSeed,
                customImagePath: controller.player1CustomImagePath,
                score: state.scoreX,
                active: p1Active,
                color: AppColors.primaryFixedDim,
              ),
              const SizedBox(width: 16),
              _Card(
                label: controller.player2Label,
                avatarSeed: controller.player2AvatarSeed,
                customImagePath: controller.player2CustomImagePath,
                score: state.scoreO,
                active: p2Active,
                color: AppColors.tertiaryFixed,
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
  final String? customImagePath;
  final int score;
  final bool active;
  final Color color;

  const _Card({
    required this.label,
    required this.score,
    required this.active,
    required this.color,
    this.avatarSeed,
    this.customImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active
                ? color.withAlpha(100)
                : AppColors.outlineVariant.withAlpha(60),
            width: active ? 1.5 : 1,
          ),
          boxShadow: active
              ? [BoxShadow(color: color.withAlpha(50), blurRadius: 16)]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatarSeed != null || customImagePath != null) ...[
              _Avatar(seed: avatarSeed ?? '', imagePath: customImagePath, active: active, color: color),
              const SizedBox(height: 6),
            ],
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: (avatarSeed != null || customImagePath != null) ? 10 : 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: active ? color : AppColors.secondaryFixed,
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
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: active ? color : Colors.white54,
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
  final String? imagePath;
  final bool active;
  final Color color;

  const _Avatar({required this.seed, required this.active, required this.color, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? color.withAlpha(180) : Colors.transparent,
          width: 2,
        ),
        boxShadow: active
            ? [BoxShadow(color: color.withAlpha(80), blurRadius: 10)]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (imagePath != null) {
      if (imagePath!.startsWith('https://')) {
        return Image.network(imagePath!, fit: BoxFit.cover,
            errorBuilder: (_, e, st) => _svgFallback());
      }
      if (imagePath!.startsWith('data:')) {
        try {
          final base64Str = imagePath!.substring(imagePath!.indexOf(',') + 1);
          final bytes = base64Decode(base64Str);
          return Image.memory(bytes, fit: BoxFit.cover,
              errorBuilder: (_, e, st) => _svgFallback());
        } catch (_) {
          return _svgFallback();
        }
      }
    }
    return _svgFallback();
  }

  Widget _svgFallback() => SvgPicture.string(multiavatar(seed), fit: BoxFit.cover);
}
