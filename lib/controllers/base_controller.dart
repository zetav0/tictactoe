import 'package:flutter/foundation.dart';
import '../models/game_model.dart';

abstract class BaseGameController extends ChangeNotifier {
  GameState get state;
  String get player1Label;
  String get player2Label;
  String? get player1AvatarSeed => null;
  String? get player2AvatarSeed => null;
  String? get player1CustomImagePath => null;
  String? get player2CustomImagePath => null;
  String get turnMessage;
  bool get isMyTurn;
  void makeMove(int index);
  void reset();
}
