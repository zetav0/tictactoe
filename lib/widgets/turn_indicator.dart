import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/base_controller.dart';
import '../models/game_model.dart';
import '../theme/app_colors.dart';

class TurnIndicator extends StatelessWidget {
  final BaseGameController controller;

  const TurnIndicator({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;

        final (String text, Color color, IconData icon) = switch (state.status) {
          GameStatus.xWins => ('Player 1 wins! 🎉', AppColors.primaryFixedDim, Icons.emoji_events),
          GameStatus.oWins => ('${controller.player2Label} wins! 🎉', AppColors.tertiaryFixed, Icons.emoji_events),
          GameStatus.draw => ("It's a draw!", Colors.white54, Icons.handshake),
          GameStatus.playing => _playingLabel(state, controller),
        };

        final contentKey = ValueKey('${state.status.index}:${state.currentPlayer.index}');

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: color.withAlpha(28),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: color.withAlpha(60)),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
                  child: child,
                ),
              ),
              child: Row(
                key: contentKey,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .custom(
                duration: 1800.ms,
                builder: (context, value, child) =>
                    Opacity(opacity: 0.75 + 0.25 * value, child: child),
              ),
        );
      },
    );
  }

  static (String, Color, IconData) _playingLabel(
    GameState state,
    BaseGameController controller,
  ) {
    final msg = controller.turnMessage;
    if (state.currentPlayer == CellValue.x) {
      return (msg, AppColors.primaryFixedDim, Icons.sports_esports);
    }
    return (msg, AppColors.tertiaryFixed, Icons.sports_esports);
  }
}
