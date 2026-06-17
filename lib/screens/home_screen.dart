import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_model.dart';
import '../providers/home_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/tappable.dart';
import '../widgets/user_avatar.dart';
import '../../main.dart' show firebaseReady;
import 'connect_four_screen.dart';
import 'game_screen.dart';
import 'multiplayer_screen.dart';
import 'profile_edit_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(gameModeProvider);
    final difficulty = ref.watch(difficultyProvider);
    final gameType = ref.watch(gameTypeProvider);
    final isC4 = gameType == GameType.connectFour;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, ref),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height
                  - MediaQuery.of(context).padding.top
                  - kToolbarHeight
                  - 80,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const Spacer(),
                  _Logo()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.2, curve: Curves.easeOut),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      isC4 ? '4 en Raya' : 'Tic Tac Toe',
                      key: ValueKey(isC4),
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      isC4 ? 'Conecta cuatro en línea.' : 'The classic game of strategy.',
                      key: ValueKey(isC4),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.white38,
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 20),
                  _GameTypePicker(
                    selected: gameType,
                    onChanged: (gt) =>
                        ref.read(gameTypeProvider.notifier).state = gt,
                  ).animate().fadeIn(delay: 380.ms).slideX(begin: -0.1),
                  const SizedBox(height: 16),
                  _ModeButton(
                    label: 'Player vs Player',
                    icon: Icons.group_rounded,
                    selected: mode == GameMode.pvp,
                    onTap: () =>
                        ref.read(gameModeProvider.notifier).state = GameMode.pvp,
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                  const SizedBox(height: 12),
                  _ModeButton(
                    label: 'Player vs AI',
                    icon: Icons.smart_toy_rounded,
                    selected: mode == GameMode.pvAi,
                    onTap: () =>
                        ref.read(gameModeProvider.notifier).state = GameMode.pvAi,
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                  const SizedBox(height: 12),
                  _OnlineButton(
                    enabled: firebaseReady,
                    onTap: () => Navigator.push(
                      context,
                      _slideRoute(MultiplayerScreen(gameType: gameType)),
                    ),
                  ).animate().fadeIn(delay: 560.ms).slideX(begin: -0.1),
                  const SizedBox(height: 16),
                  if (mode == GameMode.pvAi) ...[
                    Text(
                      'AI DIFFICULTY LEVEL',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: Colors.white38,
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 10),
                    _DifficultyPicker(
                      selected: difficulty,
                      onChanged: (d) =>
                          ref.read(difficultyProvider.notifier).state = d,
                    ).animate().fadeIn(delay: 700.ms),
                    const SizedBox(height: 16),
                  ],
                  const Spacer(),
                  _PlayButton(
                    onTap: () => Navigator.push(
                      context,
                      _slideRoute(
                        isC4
                            ? ConnectFourScreen(mode: mode, difficulty: difficulty)
                            : GameScreen(mode: mode, difficulty: difficulty),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).valueOrNull;
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.push(
          context,
          _slideRoute(const ProfileEditScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: profile == null
              ? const Icon(Icons.settings_rounded, color: Colors.white54)
              : UserAvatar(
                  seed: profile.avatarSeed,
                  imagePath: profile.customImagePath,
                  size: 36,
                ),
        ),
      ),
      title: Text(
        profile != null ? 'HI, ${profile.username.toUpperCase()}' : 'TIC TAC TOE',
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: AppColors.primaryFixedDim,
        ),
      ),
      centerTitle: true,
      actions: const [
        Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.leaderboard_rounded, color: Colors.white54),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 72,
          height: 72,
          child: CustomPaint(painter: _LogoPainter()),
        ),
      ),
    );
  }
}

PageRouteBuilder<T> _slideRoute<T>(Widget page) => PageRouteBuilder(
  pageBuilder: (context, animation, secondary) => page,
  transitionDuration: const Duration(milliseconds: 320),
  reverseTransitionDuration: const Duration(milliseconds: 280),
  transitionsBuilder: (context, animation, secondary, child) => SlideTransition(
    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  ),
);

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final xPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final oPaint = Paint()
      ..color = AppColors.oColor.withAlpha(200)
      ..strokeWidth = size.width * 0.12
      ..style = PaintingStyle.stroke;

    final pad = size.width * 0.12;
    // X
    canvas.drawLine(Offset(pad, pad), Offset(size.width - pad, size.height - pad), xPaint);
    canvas.drawLine(Offset(size.width - pad, pad), Offset(pad, size.height - pad), xPaint);
    // O (overlapping circle)
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.32,
      oPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TappableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primaryFixedDim.withAlpha(80)
                : AppColors.outlineVariant.withAlpha(60),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primaryFixedDim : Colors.white54,
              size: 22,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameTypePicker extends StatelessWidget {
  final GameType selected;
  final ValueChanged<GameType> onChanged;

  const _GameTypePicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: GameType.values.map((gt) {
          final active = gt == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(gt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: active
                    ? BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(28),
                      )
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      gt == GameType.ticTacToe
                          ? Icons.grid_view_rounded
                          : Icons.circle_outlined,
                      size: 16,
                      color: active ? Colors.white : Colors.white38,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      gt == GameType.ticTacToe ? 'Tic Tac Toe' : '4 en Raya',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DifficultyPicker extends StatelessWidget {
  final AIDifficulty selected;
  final ValueChanged<AIDifficulty> onChanged;

  const _DifficultyPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: AIDifficulty.values.map((d) {
          final active = d == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: active
                    ? BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(28),
                      )
                    : null,
                child: Text(
                  d.name[0].toUpperCase() + d.name.substring(1),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OnlineButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool enabled;
  const _OnlineButton({required this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return TappableScale(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.tertiaryFixed.withAlpha(70)),
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_rounded, color: AppColors.tertiaryFixed, size: 22),
            const SizedBox(width: 14),
            Text(
              'Online Multiplayer',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white60,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.tertiaryFixed.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'NEW',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tertiaryFixed,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PlayButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TappableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(80),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grid_view_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              'Play',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
