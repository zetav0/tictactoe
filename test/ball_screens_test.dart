import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/game/ball_in_hole_game.dart';
import 'package:tictactoe/l10n/gen/app_localizations.dart';
import 'package:tictactoe/screens/ball_in_hole_screen.dart';
import 'package:tictactoe/screens/ball_level_select_screen.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('level select shows tiles and opens level 1', (tester) async {
    await tester.pumpWidget(_wrap(const BallLevelSelectScreen()));
    await tester.pump(const Duration(seconds: 1)); // entrance animations

    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('1'));
    await tester.pump(const Duration(milliseconds: 400)); // route transition
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(BallInHoleScreen), findsOneWidget);
    expect(find.byType(GameWidget<BallInHoleGame>), findsOneWidget);

    // Let the game attach and tick a few frames without throwing.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('game screen renders HUD and survives drag input', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const BallInHoleScreen(levelIndex: 0)));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(GameWidget<BallInHoleGame>), findsOneWidget);
    expect(find.text('0:00.0'), findsOneWidget); // timer chip

    // Drag over the board (the fallback tilt input) must not throw.
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(GameWidget<BallInHoleGame>)),
    );
    await gesture.moveBy(const Offset(60, 40));
    await tester.pump(const Duration(milliseconds: 200));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));
  });
}
