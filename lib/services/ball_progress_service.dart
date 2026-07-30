import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ball_level.dart';

/// Ball in the Hole level progression: how many levels are unlocked and the
/// best completion time per level.
///
/// A ChangeNotifier singleton (same pattern as HistoryService) so the level
/// select screen updates live after a completion.
class BallProgressService extends ChangeNotifier {
  BallProgressService._();
  static final BallProgressService instance = BallProgressService._();

  static const _unlockedKey = 'ball_unlocked_levels';
  static const _bestTimesKey = 'ball_best_times';

  int? _unlocked; // count of playable levels, ≥ 1
  Map<int, int> _bestMs = {}; // 1-based level → best time in ms

  /// Number of levels the player may enter (the first locked one is
  /// `unlockedLevels + 1`). Always at least 1, never above the level count.
  int get unlockedLevels => (_unlocked ?? 1).clamp(1, BallLevel.count);

  bool isUnlocked(int level) => level <= unlockedLevels;

  Duration? bestTime(int level) {
    final ms = _bestMs[level];
    return ms == null ? null : Duration(milliseconds: ms);
  }

  Future<void> ensureLoaded() async {
    if (_unlocked != null) return;
    final prefs = await SharedPreferences.getInstance();
    _unlocked = prefs.getInt(_unlockedKey) ?? 1;
    final raw = prefs.getString(_bestTimesKey);
    if (raw != null) {
      try {
        _bestMs = {
          for (final e in (jsonDecode(raw) as Map<String, dynamic>).entries)
            int.parse(e.key): e.value as int,
        };
      } catch (_) {}
    }
    // Skip the notify when everything is still at its defaults, so a fresh
    // install doesn't rebuild the level grid mid-entrance-animation.
    if (_unlocked != 1 || _bestMs.isNotEmpty) notifyListeners();
  }

  /// Records a completed [level] (1-based). Unlocks the next level and keeps
  /// the fastest time. Returns true when [elapsed] is a new best.
  Future<bool> recordCompletion(int level, Duration elapsed) async {
    await ensureLoaded();
    final ms = elapsed.inMilliseconds;
    final previous = _bestMs[level];
    final newBest = previous == null || ms < previous;
    if (newBest) _bestMs[level] = ms;
    if (level + 1 > _unlocked!) _unlocked = level + 1;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_unlockedKey, _unlocked!);
    await prefs.setString(
      _bestTimesKey,
      jsonEncode({for (final e in _bestMs.entries) '${e.key}': e.value}),
    );
    return newBest;
  }
}
