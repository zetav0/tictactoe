import '../controllers/base_controller.dart';
import 'gen/app_localizations.dart';

/// Resolves a player's display name: an explicit name (online username)
/// wins over the semantic label.
String playerDisplayName(
        AppLocalizations l10n, PlayerLabel label, String? name) =>
    name ??
    switch (label) {
      PlayerLabel.player1 => l10n.labelPlayer1,
      PlayerLabel.player2 => l10n.labelPlayer2,
      PlayerLabel.ai => l10n.labelAi,
      PlayerLabel.opponent => l10n.labelOpponent,
    };

String turnMessageText(AppLocalizations l10n, TurnMessage message) =>
    switch (message) {
      TurnMessage.none => '',
      TurnMessage.yourTurn => l10n.yourTurn,
      TurnMessage.aiThinking => l10n.aiThinking,
      TurnMessage.player2Turn => l10n.player2Turn,
      TurnMessage.opponentTurn => l10n.opponentTurn,
    };
