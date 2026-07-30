import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/ball_level.dart';
import '../services/ball_progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/playful_theme.dart';
import '../widgets/tappable.dart';
import 'ball_in_hole_screen.dart';

/// Grid of Ball in the Hole levels: play any unlocked one, see best times.
class BallLevelSelectScreen extends StatefulWidget {
  const BallLevelSelectScreen({super.key});

  @override
  State<BallLevelSelectScreen> createState() => _BallLevelSelectScreenState();
}

class _BallLevelSelectScreenState extends State<BallLevelSelectScreen> {
  @override
  void initState() {
    super.initState();
    BallProgressService.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.gameBallInHole.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: Colors.white,
            shadows: PlayfulTheme.bubbleShadow(),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.canvasGradient),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: BallProgressService.instance,
            builder: (context, _) {
              final progress = BallProgressService.instance;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                    child: Text(
                      l10n.chooseLevel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: Colors.white60,
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                          ),
                      itemCount: BallLevel.count,
                      itemBuilder: (context, i) {
                        final level = i + 1;
                        return _LevelTile(
                              level: level,
                              unlocked: progress.isUnlocked(level),
                              bestTime: progress.bestTime(level),
                              onTap: () => Navigator.push(
                                context,
                                _slideRoute(BallInHoleScreen(levelIndex: i)),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: (60 * i).ms, duration: 300.ms)
                            .slideY(begin: 0.15, curve: Curves.easeOut);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int level;
  final bool unlocked;
  final Duration? bestTime;
  final VoidCallback onTap;

  const _LevelTile({
    required this.level,
    required this.unlocked,
    required this.bestTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final completed = bestTime != null;

    if (!unlocked) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: PlayfulTheme.cardRadius,
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: const Center(
          child: Icon(Icons.lock_rounded, color: Colors.white24, size: 28),
        ),
      );
    }

    return TappableScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: completed ? 0.16 : 0.10),
          borderRadius: PlayfulTheme.cardRadius,
          border: Border.all(
            color: completed
                ? AppColors.tertiary.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.25),
            width: completed ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$level',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                shadows: PlayfulTheme.bubbleShadow(),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              completed ? l10n.bestTime(formatBallTime(bestTime!)) : '—',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: completed ? AppColors.tertiary : Colors.white38,
              ),
            ),
          ],
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
