import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/base_controller.dart';
import '../l10n/gen/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/game_model.dart';
import '../theme/app_colors.dart';

class TurnIndicator extends StatelessWidget {
  final BaseGameController controller;

  const TurnIndicator({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;

        final (String text, Color color, IconData icon) = switch (state.status) {
          GameStatus.xWins => (
              '${l10n.playerWins(playerDisplayName(l10n, controller.player1Label, controller.player1Name))} 🎉',
              AppColors.xColor,
              Icons.emoji_events,
            ),
          GameStatus.oWins => (
              '${l10n.playerWins(playerDisplayName(l10n, controller.player2Label, controller.player2Name))} 🎉',
              AppColors.oColor,
              Icons.emoji_events,
            ),
          GameStatus.draw => (l10n.itsADraw, Colors.white54, Icons.handshake),
          GameStatus.playing => _playingLabel(l10n, state, controller),
        };

        final contentKey = ValueKey('${state.status.index}:${state.currentPlayer.index}');

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
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
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
    AppLocalizations l10n,
    GameState state,
    BaseGameController controller,
  ) {
    final msg = turnMessageText(l10n, controller.turnMessage);
    if (state.currentPlayer == CellValue.x) {
      return (msg, AppColors.xColor, Icons.sports_esports);
    }
    return (msg, AppColors.oColor, Icons.sports_esports);
  }
}
