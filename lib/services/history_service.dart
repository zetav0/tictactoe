import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match_record.dart';

/// Local match history, newest first, capped at [_maxEntries].
///
/// A ChangeNotifier singleton (same pattern as SoundService) so the game
/// controllers can record results without Riverpod and the History tab
/// updates live.
class HistoryService extends ChangeNotifier {
  HistoryService._();
  static final HistoryService instance = HistoryService._();

  static const _key = 'match_history';
  static const _maxEntries = 50;

  List<MatchRecord>? _records;

  List<MatchRecord> get records => List.unmodifiable(_records ?? const []);

  Future<void> ensureLoaded() async {
    if (_records != null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final loaded = <MatchRecord>[];
    if (raw != null) {
      try {
        for (final item in jsonDecode(raw) as List) {
          final record = MatchRecord.tryParse(item);
          if (record != null) loaded.add(record);
        }
      } catch (_) {}
    }
    _records = loaded;
    notifyListeners();
  }

  Future<void> add(MatchRecord record) async {
    await ensureLoaded();
    _records!.insert(0, record);
    if (_records!.length > _maxEntries) {
      _records!.removeRange(_maxEntries, _records!.length);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final r in _records!) r.toJson()]),
    );
  }
}
