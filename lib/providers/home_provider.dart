import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_model.dart';

final gameModeProvider = StateProvider<GameMode>((ref) => GameMode.pvAi);
final difficultyProvider = StateProvider<AIDifficulty>((ref) => AIDifficulty.medium);
final navIndexProvider = StateProvider<int>((ref) => 0);
final gameTypeProvider = StateProvider<GameType>((ref) => GameType.ticTacToe);
