import 'package:audioplayers/audioplayers.dart';

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  static const _move = 'sounds/478285__joao_janz__finger-tap-2_5.wav';
  static const _win  = 'sounds/607207__fupicat__congrats.wav';

  // Dedicated players so a win sound doesn't cut off a move sound and vice-versa.
  final AudioPlayer _movePlayer = AudioPlayer();
  final AudioPlayer _winPlayer  = AudioPlayer();

  Future<void> playMove() async {
    try {
      await _movePlayer.play(AssetSource(_move));
    } catch (_) {}
  }

  Future<void> playWin() async {
    try {
      await _winPlayer.play(AssetSource(_win));
    } catch (_) {}
  }
}
