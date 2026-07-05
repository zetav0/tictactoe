import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/game_model.dart';
import '../providers/home_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/playful_theme.dart';
import '../widgets/tappable.dart';
import '../widgets/user_avatar.dart';
import '../../main.dart' show firebaseReady;
import 'connect_four_screen.dart';
import 'game_screen.dart';
import 'multiplayer_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(gameModeProvider);
    final difficulty = ref.watch(difficultyProvider);
    final gameType = ref.watch(gameTypeProvider);
    final isC4 = gameType == GameType.connectFour;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context, ref),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.canvasGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Real space under the transparent app bar. When it isn't enough
              // for the full-size layout, shrink logo/typography/paddings so
              // everything fits without scrolling (scroll stays as a fallback
              // for extremely small screens).
              final available = constraints.maxHeight - kToolbarHeight;
              final compact = available < 740;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, kToolbarHeight, 24, 0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: available),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const Spacer(),
                        _Logo(size: compact ? 84 : 120)
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: -0.2, curve: Curves.easeOut),
                        SizedBox(height: compact ? 10 : 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            isC4 ? l10n.gameConnectFour : l10n.gameTicTacToe,
                            key: ValueKey(isC4),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: compact ? 28 : 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              shadows: PlayfulTheme.bubbleShadow(),
                            ),
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        SizedBox(height: compact ? 4 : 6),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            isC4 ? l10n.c4Tagline : l10n.tttTagline,
                            key: ValueKey(isC4),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: compact ? 13 : 15,
                              color: Colors.white60,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                        SizedBox(height: compact ? 14 : 24),
                        _GameTypePicker(
                          selected: gameType,
                          onChanged: (gt) =>
                              ref.read(gameTypeProvider.notifier).state = gt,
                        ).animate().fadeIn(delay: 380.ms).slideX(begin: -0.1),
                        SizedBox(height: compact ? 10 : 16),
                        _ModeButton(
                          compact: compact,
                          label: l10n.playerVsPlayer,
                          icon: Icons.group_rounded,
                          selected: mode == GameMode.pvp,
                          onTap: () =>
                              ref.read(gameModeProvider.notifier).state =
                                  GameMode.pvp,
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                        SizedBox(height: compact ? 8 : 12),
                        _ModeButton(
                          compact: compact,
                          label: l10n.playerVsAi,
                          icon: Icons.smart_toy_rounded,
                          selected: mode == GameMode.pvAi,
                          onTap: () =>
                              ref.read(gameModeProvider.notifier).state =
                                  GameMode.pvAi,
                        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                        SizedBox(height: compact ? 8 : 12),
                        _OnlineButton(
                          compact: compact,
                          enabled: firebaseReady,
                          onTap: () => Navigator.push(
                            context,
                            _slideRoute(MultiplayerScreen(gameType: gameType)),
                          ),
                        ).animate().fadeIn(delay: 560.ms).slideX(begin: -0.1),
                        SizedBox(height: compact ? 10 : 16),
                        if (mode == GameMode.pvAi) ...[
                          Text(
                            l10n.aiDifficultyLevel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: Colors.white60,
                            ),
                          ).animate().fadeIn(delay: 600.ms),
                          SizedBox(height: compact ? 6 : 10),
                          _DifficultyPicker(
                            selected: difficulty,
                            onChanged: (d) =>
                                ref.read(difficultyProvider.notifier).state = d,
                          ).animate().fadeIn(delay: 700.ms),
                          SizedBox(height: compact ? 10 : 16),
                        ],
                        const Spacer(),
                        _PlayButton(
                          compact: compact,
                          onTap: () => Navigator.push(
                            context,
                            _slideRoute(
                              isC4
                                  ? ConnectFourScreen(
                                      mode: mode,
                                      difficulty: difficulty,
                                    )
                                  : GameScreen(
                                      mode: mode,
                                      difficulty: difficulty,
                                    ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
                        SizedBox(height: compact ? 10 : 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).valueOrNull;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        // Jump to the Profile tab of the shell.
        onTap: () => ref.read(navIndexProvider.notifier).state = 2,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: profile == null
              ? const Icon(Icons.settings_rounded, color: Colors.white70)
              : UserAvatar(seed: profile.avatarSeed, size: 36),
        ),
      ),
      title: Text(
        profile != null
            ? AppLocalizations.of(
                context,
              ).hiUser(profile.username.toUpperCase())
            : 'GAME BLAST',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: Colors.white,
          shadows: PlayfulTheme.bubbleShadow(),
        ),
      ),
      centerTitle: true,
      actions: const [
        Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.leaderboard_rounded, color: Colors.white70),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  final double size;
  const _Logo({this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.canvasGradientTop.withValues(alpha: 0.5),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.6,
          height: size * 0.6,
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
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
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
      ..color = AppColors.oColor
      ..strokeWidth = size.width * 0.12
      ..style = PaintingStyle.stroke;

    final pad = size.width * 0.12;
    canvas.drawLine(
      Offset(pad, pad),
      Offset(size.width - pad, size.height - pad),
      xPaint,
    );
    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(pad, size.height - pad),
      xPaint,
    );
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
  final bool compact;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return TappableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: compact ? 13 : 18,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.2),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? PlayfulTheme.ambientShadow(
                  color: AppColors.primaryContainer,
                  opacity: 0.4,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (selected) ...[
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
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
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
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
                      color: active ? Colors.white : Colors.white54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      gt == GameType.ticTacToe
                          ? AppLocalizations.of(context).gameTicTacToe
                          : AppLocalizations.of(context).gameConnectFour,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : Colors.white54,
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
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      )
                    : null,
                child: Text(
                  switch (d) {
                    AIDifficulty.easy => AppLocalizations.of(
                      context,
                    ).difficultyEasy,
                    AIDifficulty.medium => AppLocalizations.of(
                      context,
                    ).difficultyMedium,
                    AIDifficulty.hard => AppLocalizations.of(
                      context,
                    ).difficultyHard,
                  },
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : Colors.white54,
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
  final bool compact;
  const _OnlineButton({
    required this.onTap,
    this.enabled = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return TappableScale(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: compact ? 13 : 18,
            horizontal: 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.tertiary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.tertiary.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.wifi_rounded,
                  color: AppColors.tertiary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                AppLocalizations.of(context).onlineMultiplayer,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocalizations.of(context).badgeNew,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onTertiary,
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
  final bool compact;

  const _PlayButton({required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return TappableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: compact ? 15 : 20),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: PlayfulTheme.secondaryLip(depth: 6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.onSecondary,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context).playNow,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
