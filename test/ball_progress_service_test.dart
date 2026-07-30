import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/services/ball_progress_service.dart';

void main() {
  test('completions unlock the next level and keep the best time', () async {
    SharedPreferences.setMockInitialValues({});
    final service = BallProgressService.instance;
    await service.ensureLoaded();

    expect(service.unlockedLevels, 1);
    expect(service.isUnlocked(2), isFalse);
    expect(service.bestTime(1), isNull);

    var newBest = await service.recordCompletion(
      1,
      const Duration(seconds: 30),
    );
    expect(newBest, isTrue);
    expect(service.isUnlocked(2), isTrue);
    expect(service.bestTime(1), const Duration(seconds: 30));

    // Slower run: level stays completed with the old best.
    newBest = await service.recordCompletion(1, const Duration(seconds: 45));
    expect(newBest, isFalse);
    expect(service.bestTime(1), const Duration(seconds: 30));

    // Faster run: new best.
    newBest = await service.recordCompletion(1, const Duration(seconds: 20));
    expect(newBest, isTrue);
    expect(service.bestTime(1), const Duration(seconds: 20));

    // Replaying an old level never re-locks progress.
    await service.recordCompletion(2, const Duration(seconds: 10));
    await service.recordCompletion(1, const Duration(seconds: 5));
    expect(service.unlockedLevels, 3);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('ball_unlocked_levels'), 3);
    expect(prefs.getString('ball_best_times'), isNotNull);
  });
}
