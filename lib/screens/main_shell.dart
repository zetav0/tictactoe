import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';
import '../widgets/bottom_nav.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile_edit_screen.dart';

/// Root shell hosting the three bottom-nav tabs. IndexedStack keeps every
/// tab's state alive while switching. Game screens are pushed on top of the
/// shell and deliberately have no bottom nav.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          HomeScreen(),
          HistoryScreen(),
          ProfileEditScreen(embedded: true),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
