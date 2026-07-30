import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService with WidgetsBindingObserver {
  SoundService._();
  static final SoundService instance = SoundService._();

  static const _move = 'sounds/478285__joao_janz__finger-tap-2_5.wav';
  static const _win  = 'sounds/607207__fupicat__congrats.wav';
  static const _music =
      'sounds/land_of_books_youtube-happy-game-day-x9-229678.mp3';

  static const _musicEnabledKey = 'music_enabled';
  static const _musicVolume = 0.35; // background level, under the SFX

  // Dedicated players so a win sound doesn't cut off a move sound and vice-versa.
  final AudioPlayer _movePlayer = AudioPlayer();
  final AudioPlayer _winPlayer  = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  /// Whether background music is enabled (user setting, persisted).
  final ValueNotifier<bool> musicEnabled = ValueNotifier(true);

  bool _musicStarted = false;

  /// Loads the music preference and starts the loop. Call once at startup.
  /// On web the play attempt is blocked until the first user gesture —
  /// [ensureMusicStarted] retries from the app's global tap listener.
  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    try {
      final prefs = await SharedPreferences.getInstance();
      musicEnabled.value = prefs.getBool(_musicEnabledKey) ?? true;
    } catch (_) {}
    await ensureMusicStarted();
  }

  Future<void> ensureMusicStarted() async {
    if (_musicStarted || !musicEnabled.value) return;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource(_music), volume: _musicVolume);
      _musicStarted = true;
    } catch (_) {}
  }

  Future<void> setMusicEnabled(bool enabled) async {
    musicEnabled.value = enabled;
    if (enabled) {
      await ensureMusicStarted();
    } else {
      _musicStarted = false;
      try {
        await _musicPlayer.stop();
      } catch (_) {}
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_musicEnabledKey, enabled);
    } catch (_) {}
  }

  /// Pause the loop when the app goes to the background, resume on return.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_musicStarted) return;
    try {
      if (state == AppLifecycleState.resumed) {
        _musicPlayer.resume();
      } else if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive ||
          state == AppLifecycleState.hidden) {
        _musicPlayer.pause();
      }
    } catch (_) {}
  }

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
