import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/connect_four_base_controller.dart';
import '../models/game_model.dart';
import '../utils/connect_four_logic.dart';

/// 7×6 Connect Four board. Accepts any [ConnectFourBaseController] so it
/// works for both local (AI/PvP) and remote (online) games.
class ConnectFourBoard extends StatelessWidget {
  final ConnectFourBaseController controller;

  const ConnectFourBoard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // ClipRRect clips the drop animation so pieces appear to fall from the top
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final state = controller.state;
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xCC322E3D),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
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

    // Drop-with-bounce animation: skip for winning cell so the win entrance
    // animation takes visual priority.
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

// ── Cell widgets ───────────────────────────────────────────────────────────────

class C4Slot extends StatelessWidget {
  const C4Slot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xCC18161D),
      ),
    );
  }
}

class C4Token extends StatelessWidget {
  final bool isX;

  const C4Token({super.key, required this.isX});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 0.85,
          colors: isX
              ? const [Color(0xFF6750A4), Color(0xFF4F378A)]
              : const [Color(0xFFFFAB91), Color(0xFFFF8A80)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isX ? const Color(0xFF6750A4) : const Color(0xFFFF8A80))
                .withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

/// Wraps a winning token with a staggered entrance bounce + continuous gold pulse.
///
/// [sequenceIndex] (0–3) controls the stagger delay so the 4 winning cells
/// light up one after another, clearly revealing the winning line.
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

    // Scale: 1.0 → 1.35 → 0.93 → 1.06 → 1.0
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
