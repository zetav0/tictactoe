import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/app.dart';
import 'package:tictactoe/models/user_profile.dart';

void main() {
  testWidgets('shows profile setup on first launch', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: TicTacToeApp()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('shows HomeScreen when a profile exists', (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_profile':
          const UserProfile(username: 'Iso', avatarSeed: 'Cosmos').encode(),
    });

    await tester.pumpWidget(const ProviderScope(child: TicTacToeApp()));
    await tester.pumpAndSettle();

    expect(find.text('HI, ISO'), findsOneWidget);
    expect(find.text('PLAY NOW'), findsOneWidget);
  });

  testWidgets('renders in Spanish when the device locale is es',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_profile':
          const UserProfile(username: 'Iso', avatarSeed: 'Cosmos').encode(),
    });
    await tester.pumpWidget(const ProviderScope(child: TicTacToeApp()));
    await tester.binding.setLocale('es', '');
    await tester.pumpAndSettle();

    expect(find.text('HOLA, ISO'), findsOneWidget);
    expect(find.text('JUGAR AHORA'), findsOneWidget);
  });
}
