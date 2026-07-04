import 'package:flutter/material.dart';

class AppColors {
  // === Surfaces ===
  static const Color background = Color(0xFF121414);
  static const Color surfaceContainer = Color(0xFF1E2020);
  static const Color surfaceContainerHigh = Color(0xFF282A2B);
  static const Color surfaceContainerLow = Color(0xFF1A1C1C);
  static const Color surfaceContainerLowest = Color(0xFF0C0F0F);
  static const Color surfaceContainerHighest = Color(0xFF333535);
  static const Color surfaceBright = Color(0xFF37393A);
  static const Color surfaceVariant = Color(0xFF333535);
  static const Color onSurface = Color(0xFFE2E2E2);
  static const Color onSurfaceVariant = Color(0xFFC3C6D7);

  // === Primary — Royal Blue ===
  static const Color primary = Color(0xFFB4C5FF);
  static const Color primaryContainer = Color(0xFF2B65EC);
  static const Color onPrimary = Color(0xFF002A78);
  static const Color primaryFixed = Color(0xFFDBE1FF);
  static const Color primaryFixedDim = Color(0xFFB4C5FF);
  static const Color onPrimaryFixed = Color(0xFF00174B);
  static const Color onPrimaryFixedVariant = Color(0xFF003DA9);
  static const Color inversePrimary = Color(0xFF0553DA);

  // === Secondary — Action Yellow ===
  static const Color secondary = Color(0xFFFFBA38);
  static const Color secondaryContainer = Color(0xFFDB9900);
  static const Color onSecondary = Color(0xFF432C00);
  static const Color secondaryFixed = Color(0xFFFFDEAC);
  static const Color secondaryFixedDim = Color(0xFFFFBA38);

  // === Tertiary — Success Green ===
  static const Color tertiary = Color(0xFF5EDDA0);
  static const Color tertiaryContainer = Color(0xFF007F53);
  static const Color onTertiary = Color(0xFF003822);
  static const Color tertiaryFixed = Color(0xFF7CFABB);
  static const Color tertiaryFixedDim = Color(0xFF5EDDA0);

  // === Outline ===
  static const Color outline = Color(0xFF8D90A0);
  static const Color outlineVariant = Color(0xFF434655);

  // === Canvas Gradient (game & home screens) ===
  static const Color canvasGradientTop = Color(0xFF1E4DE2);
  static const Color canvasGradientBottom = Color(0xFF002A78);

  static const LinearGradient canvasGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [canvasGradientTop, canvasGradientBottom],
  );

  // === Game Pieces ===
  static const Color xColor = Color(0xFFB4C5FF);
  static const Color xGlow = Color(0xFF2B65EC);
  static const Color oColor = Color(0xFFFFBA38);
  static const Color oGlow = Color(0xFFDB9900);
  static const Color winLine = Color(0xFF5EDDA0);
}
