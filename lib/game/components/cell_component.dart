import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../../models/game_model.dart';
import '../../theme/app_colors.dart';

class CellComponent extends PositionComponent {
  final int index;

  CellValue _value = CellValue.empty;
  bool _isWin = false;
  double _pieceT = 0;
  bool _animating = false;
  double _pulseT = 0;

  CellComponent({required this.index});

  void setValue(CellValue newValue) {
    if (_value == newValue) return;
    _value = newValue;
    if (newValue != CellValue.empty) {
      _pieceT = 0;
      _animating = true;
    }
  }

  void setWin(bool win) {
    _isWin = win;
    if (win) _pulseT = 0;
  }

  @override
  void update(double dt) {
    if (_animating) {
      _pieceT = (_pieceT + dt * 4.5).clamp(0.0, 1.0);
      if (_pieceT >= 1) _animating = false;
    }
    if (_isWin) _pulseT += dt;
  }

  @override
  void render(Canvas canvas) {
    _drawBackground(canvas);
    if (_value != CellValue.empty) _drawPiece(canvas);
  }

  void _drawBackground(Canvas canvas) {
    final Color bg;
    if (_isWin) {
      final pulse = (sin(_pulseT * 3) + 1) / 2;
      final glow = _value == CellValue.x ? AppColors.xGlow : AppColors.oGlow;
      bg = Color.lerp(AppColors.surfaceContainerHigh, glow.withAlpha(80), pulse)!;
    } else {
      bg = AppColors.surfaceContainerHigh;
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Radius.circular(size.x * 0.18),
      ),
      Paint()..color = bg,
    );
  }

  void _drawPiece(Canvas canvas) {
    final t = _easeBackOut(_pieceT);
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(t);
    canvas.translate(-size.x / 2, -size.y / 2);
    if (_value == CellValue.x) {
      _drawX(canvas);
    } else {
      _drawO(canvas);
    }
    canvas.restore();
  }

  void _drawX(Canvas canvas) {
    final pad = size.x * 0.22;
    final sw = size.x * 0.13;

    final glow = Paint()
      ..color = AppColors.xGlow.withAlpha(100)
      ..strokeWidth = sw + 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final main = Paint()
      ..color = AppColors.xColor
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final p in [glow, main]) {
      canvas.drawLine(Offset(pad, pad), Offset(size.x - pad, size.y - pad), p);
      canvas.drawLine(Offset(size.x - pad, pad), Offset(pad, size.y - pad), p);
    }
  }

  void _drawO(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x * 0.28;
    final sw = size.x * 0.11;

    final glow = Paint()
      ..color = AppColors.oGlow.withAlpha(100)
      ..strokeWidth = sw + 10
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final main = Paint()
      ..color = AppColors.oColor
      ..strokeWidth = sw
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, glow);
    canvas.drawCircle(center, radius, main);
  }

  // easeOutBack curve approximation
  double _easeBackOut(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    final u = t - 1;
    return 1 + c3 * u * u * u + c1 * u * u;
  }
}
