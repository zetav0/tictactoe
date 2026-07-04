import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Design utilities for the Playful Edition:
/// — Royal-blue canvas gradient with subtle dot pattern
/// — Glassmorphism panels
/// — 3-D buttons with a coloured "lip" bottom shadow
/// — Hyper-rounded corners (16 cells, 24 cards, pill buttons)

class PlayfulTheme {
  // ── Corner radii ───────────────────────────────────────────────────────────
  static const double radiusCell = 16;
  static const double radiusCard = 24;
  static const double radiusBtn = 24;

  static const BorderRadius cellRadius = BorderRadius.all(Radius.circular(radiusCell));
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius btnRadius = BorderRadius.all(Radius.circular(radiusBtn));

  // ── Canvas gradient ────────────────────────────────────────────────────────
  static BoxDecoration canvasDecoration() => const BoxDecoration(
        gradient: AppColors.canvasGradient,
      );

  // ── Glassmorphism panel ────────────────────────────────────────────────────
  static BoxDecoration glassDecoration({
    double opacity = 0.12,
    double borderOpacity = 0.25,
  }) =>
      BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: cardRadius,
        border: Border.all(color: Colors.white.withValues(alpha: borderOpacity)),
      );

  // ── 3-D button "lip" bottom shadow ────────────────────────────────────────
  static List<BoxShadow> lipShadow(Color lipColor, {double depth = 6}) => [
        BoxShadow(
          color: lipColor,
          offset: Offset(0, depth),
          blurRadius: 0,
        ),
      ];

  static List<BoxShadow> primaryLip({double depth = 6}) =>
      lipShadow(AppColors.onPrimaryFixedVariant, depth: depth);

  static List<BoxShadow> secondaryLip({double depth = 6}) =>
      lipShadow(AppColors.secondaryContainer, depth: depth);

  static List<BoxShadow> tertiaryLip({double depth = 6}) =>
      lipShadow(AppColors.tertiaryContainer, depth: depth);

  // ── Inner glow (top highlight on buttons) ─────────────────────────────────
  static List<BoxShadow> innerHighlight() => [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.35),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ];

  // ── Ambient floating shadow ────────────────────────────────────────────────
  static List<BoxShadow> ambientShadow({
    Color? color,
    double blur = 12,
    double opacity = 0.25,
  }) =>
      [
        BoxShadow(
          color: (color ?? AppColors.canvasGradientBottom).withValues(alpha: opacity),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ];

  // ── Board cell ────────────────────────────────────────────────────────────
  static BoxDecoration cellDecoration() => BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: cellRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            offset: const Offset(0, -4),
            blurRadius: 0,
          ),
        ],
      );

  // ── Board container ────────────────────────────────────────────────────────
  static BoxDecoration boardDecoration() => BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.all(Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // ── Bubble text drop-shadow ────────────────────────────────────────────────
  static List<Shadow> bubbleShadow() => [
        Shadow(
          color: Colors.black.withValues(alpha: 0.25),
          offset: const Offset(0, 4),
          blurRadius: 0,
        ),
      ];
}

/// Full-screen background widget that paints the royal-blue gradient plus the
/// subtle white dot grid used across all game screens.
class PlayfulBackground extends StatelessWidget {
  const PlayfulBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotGridPainter(),
      child: DecoratedBox(
        decoration: PlayfulTheme.canvasDecoration(),
        child: child,
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const radius = 1.0;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => false;
}
