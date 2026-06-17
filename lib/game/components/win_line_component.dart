import 'dart:ui';
import 'package:flame/components.dart';
import '../../theme/app_colors.dart';

class WinLineComponent extends Component {
  final Vector2 start;
  final Vector2 end;
  double _progress = 0;

  WinLineComponent({required this.start, required this.end});

  @override
  void update(double dt) {
    _progress = (_progress + dt * 2.5).clamp(0, 1.0);
  }

  @override
  void render(Canvas canvas) {
    if (_progress <= 0) return;

    final dir = end - start;
    final current = start + dir * _progress;

    final glowPaint = Paint()
      ..color = AppColors.winLine.withValues(alpha: 0.35)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final linePaint = Paint()
      ..color = AppColors.winLine
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final s = Offset(start.x, start.y);
    final e = Offset(current.x, current.y);

    canvas.drawLine(s, e, glowPaint);
    canvas.drawLine(s, e, linePaint);
  }
}
