import 'package:flutter/foundation.dart';
import '../models/game_model.dart';

/// Semantic identity of a player slot; the UI maps it to a localized string.
enum PlayerLabel { player1, player2, ai, opponent }

/// Semantic turn state; the UI maps it to a localized message.
enum TurnMessage { none, yourTurn, aiThinking, player2Turn, opponentTurn }

abstract class BaseGameController extends ChangeNotifier {
  GameState get state;
  PlayerLabel get player1Label;
  PlayerLabel get player2Label;

  /// Display name (e.g. an online username) that overrides the label when set.
  String? get player1Name => null;
  String? get player2Name => null;

  String? get player1AvatarSeed => null;
  String? get player2AvatarSeed => null;
  TurnMessage get turnMessage;
  bool get isMyTurn;
  void makeMove(int index);
  void reset();
}
