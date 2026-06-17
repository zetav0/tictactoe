import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/app.dart';

void main() {
  testWidgets('App loads HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TicTacToeApp()),
    );
    expect(find.text('TIC TAC TOE'), findsWidgets);
  });
}
