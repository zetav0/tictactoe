import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/connect_four_base_controller.dart';
import '../models/game_model.dart';
import '../theme/app_colors.dart';
import '../utils/connect_four_logic.dart';

/// 7×6 Connect Four board styled after the Playful Edition stitch design:
/// — Royal-blue board container (#2B65EC) with a B4C5FF 8px bevel lip
/// — Dark recessed holes (inner-shadow approximation via radial gradient)
/// — Glossy red tokens for Player 1, glossy yellow tokens for Player 2
class ConnectFourBoard extends StatelessWidget {
  final ConnectFourBaseController controller;

  const ConnectFourBoard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final state = controller.state;
          return Container(
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                // 3D bevel lip (light blue bottom border)
                BoxShadow(
                  color: AppColors.primary,
                  offset: const Offset(0, 8),
                  blurRadius: 0,
                ),
                // Depth ambient shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: List.generate(
                c4Cols,
                (col) => Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: state.status == GameStatus.playing && controller.isMyTurn
                        ? () => controller.makeMove(col)
                        : null,
                    child: Column(
                      children: List.generate(
                        c4Rows,
                        (row) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: _buildCell(state, row * c4Cols + col),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCell(GameState state, int index) {
    final value = state.board[index];
    final winLine = state.winLine;
    final winIdx = winLine?.indexOf(index) ?? -1;
    final isWin = winIdx >= 0;
    final isLastPlaced = controller.lastPlacedIndex == index;

    if (value == CellValue.empty) {
      return const C4Slot();
    }

    final isX = value == CellValue.x;
    Widget token = C4Token(isX: isX);

    if (isLastPlaced && !isWin) {
      token = token
          .animate(key: ValueKey('t${index}_v${controller.moveCount}'))
          .moveY(begin: -420, end: 0, duration: 560.ms, curve: Curves.bounceOut)
          .fadeIn(duration: 80.ms);
    }

    if (isWin) {
      return C4WinToken(sequenceIndex: winIdx, child: token);
    }

    return token;
  }
}

// ── Empty slot ─────────────────────────────────────────────────────────────────

class C4Slot extends StatelessWidget {
  const C4Slot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        // Dark navy circle simulating a recessed hole in the blue board
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [
            Color(0xFF0F2660), // lighter center
            Color(0xFF060E2A), // very dark edge
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 6,
            spreadRadius: -1,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }
}

// ── Game chip (token) ──────────────────────────────────────────────────────────

class C4Token extends StatelessWidget {
  final bool isX;

  const C4Token({super.key, required this.isX});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Main chip body with radial gradient matching the stitch design
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.4, -0.4),
              radius: 0.9,
              colors: isX
                  ? const [Color(0xFFFF6B6B), Color(0xFF93000A)] // red chip
                  : const [Color(0xFFFFDEAC), Color(0xFFDB9900)], // yellow chip
            ),
            boxShadow: [
              // Inner-shadow approximation (dark offset inside)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                spreadRadius: -2,
              ),
              // Drop shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        // Gloss highlight (white circle at top-left ~15% from edge)
        Align(
          alignment: const Alignment(-0.55, -0.55),
          child: FractionallySizedBox(
            widthFactor: 0.28,
            heightFactor: 0.28,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.38),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Win token with staggered bounce + continuous pulse ─────────────────────────

class C4WinToken extends StatefulWidget {
  final Widget child;
  final int sequenceIndex;

  const C4WinToken({super.key, required this.sequenceIndex, required this.child});

  @override
  State<C4WinToken> createState() => _C4WinTokenState();
}

class _C4WinTokenState extends State<C4WinToken> with TickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceScale;
  late final Animation<double> _bounceGlow;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _bounceCtrl = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _bounceScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.35).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 0.93).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.93, end: 1.06).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
    ]).animate(_bounceCtrl);

    _bounceGlow = CurvedAnimation(
      parent: _bounceCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

    Future.delayed(Duration(milliseconds: widget.sequenceIndex * 160), () {
      if (!mounted) return;
      _bounceCtrl.forward().then((_) {
        if (!mounted) return;
        _pulseCtrl.repeat(reverse: true);
      });
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceCtrl, _pulseCtrl]),
      builder: (context, child) {
        final scale = _bounceCtrl.isAnimating || _bounceCtrl.isCompleted
            ? _bounceScale.value
            : 1.0;
        final entranceGlow = _bounceCtrl.isAnimating ? _bounceGlow.value : 0.0;
        final pulseGlow = _pulseCtrl.isAnimating ? _pulse.value : 0.0;
        final glowAlpha = (entranceGlow * 0.95 + pulseGlow * 0.75).clamp(0.0, 1.0);
        final blurRadius = entranceGlow * 36 + pulseGlow * 22;
        final spreadRadius = entranceGlow * 5 + pulseGlow * 2;

        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: glowAlpha),
                  blurRadius: blurRadius,
                  spreadRadius: spreadRadius,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
