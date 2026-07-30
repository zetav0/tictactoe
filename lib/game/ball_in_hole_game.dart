import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:sensors_plus/sensors_plus.dart';

import '../models/ball_level.dart';
import '../services/sound_service.dart';
import '../theme/app_colors.dart';

/// Logical pixels per maze cell (fixed-resolution camera, so the actual
/// on-screen size is whatever the GameWidget gets).
const double _cell = 64;

const double _ballRadius = 0.30 * _cell;
const double _trapRadius = 0.36 * _cell; // painted size
const double _goalRadius = 0.40 * _cell;
const double _trapCapture = 0.34 * _cell; // ball centre within this → falls
const double _goalCapture = 0.42 * _cell;

const double _maxAccel = 22 * _cell; // at full tilt, px/s²
const double _maxSpeed = 20 * _cell;
const double _friction = 1.6; // exponential damping factor
const double _restitution = 0.42;
const double _fullTiltAccel = 5.0; // sensor m/s² that maps to full tilt
const double _fullDragRadius = 80.0; // drag px that maps to full tilt

enum _Phase { playing, done }

/// Tilt-the-maze minigame: roll the ball to the goal hole, avoid the traps.
///
/// Input is the device accelerometer when available (portrait-only app, so no
/// orientation remapping) with an on-screen drag joystick as fallback — the
/// hosting widget forwards pan gestures to [dragStart]/[dragUpdate]/[dragEnd].
/// Unlike the other games this one is single-player and has no controller;
/// results are reported through [onWin]/[onFall].
class BallInHoleGame extends FlameGame {
  final BallLevel level;
  final void Function(Duration elapsed)? onWin;
  final VoidCallback? onFall;

  /// Live play time, driven by the game loop (pauses with the game).
  final ValueNotifier<Duration> elapsed = ValueNotifier(Duration.zero);

  /// Times the ball fell into a trap this attempt.
  final ValueNotifier<int> falls = ValueNotifier(0);

  /// Turns true after the first accelerometer event — lets the UI pick the
  /// "tilt" vs "drag" hint.
  final ValueNotifier<bool> hasSensor = ValueNotifier(false);

  BallInHoleGame({required this.level, this.onWin, this.onFall})
    : super(
        camera: CameraComponent.withFixedResolution(
          width: level.cols * _cell,
          height: level.rows * _cell,
        ),
      );

  late final _BallComponent _ball;
  StreamSubscription<AccelerometerEvent>? _accelSub;

  final Vector2 _sensorTilt = Vector2.zero();
  Vector2? _dragTilt;
  Offset? _dragOrigin;

  _Phase _phase = _Phase.playing;
  double _elapsedSeconds = 0;

  Vector2 get _tilt => _dragTilt ?? _sensorTilt;

  Vector2 cellToWorld(math.Point<double> p) => Vector2(p.x, p.y) * _cell;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.position = Vector2(
      level.cols * _cell / 2,
      level.rows * _cell / 2,
    );

    world.add(_MazeComponent(level: level));
    _ball = _BallComponent(game: this)..position = cellToWorld(level.start);
    world.add(_ball);

    _listenToAccelerometer();
  }

  void _listenToAccelerometer() {
    try {
      _accelSub =
          accelerometerEventStream(
            samplingPeriod: SensorInterval.gameInterval,
          ).listen(
            (e) {
              if (!hasSensor.value) hasSensor.value = true;
              // Portrait screen-space gravity: tilt right → roll right (-x),
              // raise the top edge → roll down (+y). Smoothed to kill jitter.
              final raw = Vector2(-e.x, e.y) / _fullTiltAccel;
              if (raw.length > 1) raw.normalize();
              _sensorTilt.setFrom(_sensorTilt + (raw - _sensorTilt) * 0.3);
            },
            // No accelerometer (desktop web): drag input remains.
            onError: (Object _) => _accelSub?.cancel(),
            cancelOnError: true,
          );
    } catch (_) {}
  }

  // ── Drag fallback (virtual joystick from the pan origin) ──────────────────

  void dragStart(Offset position) {
    _dragOrigin = position;
    _dragTilt = Vector2.zero();
  }

  void dragUpdate(Offset position) {
    final origin = _dragOrigin;
    if (origin == null) return;
    final tilt =
        Vector2(position.dx - origin.dx, position.dy - origin.dy) /
        _fullDragRadius;
    if (tilt.length > 1) tilt.normalize();
    _dragTilt = tilt;
  }

  void dragEnd() {
    _dragOrigin = null;
    _dragTilt = null;
  }

  // ── Game flow ──────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    if (_phase != _Phase.done) {
      _elapsedSeconds += dt;
      final next = Duration(milliseconds: (_elapsedSeconds * 1000).round());
      // Throttle notifications to visible 0.1 s steps.
      if (next.inMilliseconds ~/ 100 != elapsed.value.inMilliseconds ~/ 100) {
        elapsed.value = next;
      }
    }
  }

  /// Restart the current level from scratch.
  void resetLevel() {
    _phase = _Phase.playing;
    _elapsedSeconds = 0;
    elapsed.value = Duration.zero;
    falls.value = 0;
    _ball.respawn();
  }

  void _onBallSank({required bool won}) {
    if (won) {
      _phase = _Phase.done;
      elapsed.value = Duration(milliseconds: (_elapsedSeconds * 1000).round());
      SoundService.instance.playWin();
      HapticFeedback.heavyImpact();
      onWin?.call(elapsed.value);
    } else {
      falls.value++;
      _phase = _Phase.playing;
      _ball.respawn();
      onFall?.call();
    }
  }

  @override
  void onRemove() {
    _accelSub?.cancel();
    elapsed.dispose();
    falls.dispose();
    hasSensor.dispose();
    super.onRemove();
  }
}

// ── Ball ─────────────────────────────────────────────────────────────────────

class _BallComponent extends PositionComponent {
  final BallInHoleGame game;

  _BallComponent({required this.game})
    : super(size: Vector2.all(_ballRadius * 2), anchor: Anchor.center);

  final Vector2 _velocity = Vector2.zero();

  // Sink animation state (falling into a hole).
  Vector2? _sinkTarget;
  bool _sinkWon = false;
  double _sinkT = 0;
  double _scale = 1;

  double _sinceLastBump = 1;

  void respawn() {
    position = game.cellToWorld(game.level.start);
    _velocity.setZero();
    _sinkTarget = null;
    _sinkT = 0;
    _scale = 1;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game._phase == _Phase.done) return;
    if (_sinkTarget != null) {
      _updateSink(dt);
      return;
    }

    _sinceLastBump += dt;

    _velocity.add(game._tilt * _maxAccel * dt);
    _velocity.scale(math.exp(-_friction * dt));
    if (_velocity.length > _maxSpeed) {
      _velocity
        ..normalize()
        ..scale(_maxSpeed);
    }

    // Substeps keep each move under a quarter cell so the ball can't tunnel
    // through a wall at high speed.
    final travel = _velocity.length * dt;
    final steps = (travel / (_cell * 0.25)).ceil().clamp(1, 8);
    for (var i = 0; i < steps; i++) {
      position.add(_velocity * (dt / steps));
      _collideWithWalls();
    }

    _checkHoles();
  }

  void _updateSink(double dt) {
    _sinkT = (_sinkT + dt / 0.45).clamp(0.0, 1.0);
    final t = Curves.easeIn.transform(_sinkT);
    position.setFrom(position + (_sinkTarget! - position) * (t * 0.35 + 0.2));
    _scale = 1 - t * 0.85;
    if (_sinkT >= 1) {
      final won = _sinkWon;
      _sinkTarget = null;
      game._onBallSank(won: won);
    }
  }

  void _startSink(Vector2 hole, {required bool won}) {
    _sinkTarget = hole.clone();
    _sinkWon = won;
    _sinkT = 0;
    _velocity.setZero();
    if (!won) {
      SoundService.instance.playMove();
      HapticFeedback.mediumImpact();
    }
  }

  void _checkHoles() {
    final level = game.level;
    if (position.distanceTo(game.cellToWorld(level.goal)) < _goalCapture) {
      _startSink(game.cellToWorld(level.goal), won: true);
      return;
    }
    for (final trap in level.traps) {
      if (position.distanceTo(game.cellToWorld(trap)) < _trapCapture) {
        _startSink(game.cellToWorld(trap), won: false);
        return;
      }
    }
  }

  void _collideWithWalls() {
    final level = game.level;
    final minC = ((position.x - _ballRadius) / _cell).floor();
    final maxC = ((position.x + _ballRadius) / _cell).floor();
    final minR = ((position.y - _ballRadius) / _cell).floor();
    final maxR = ((position.y + _ballRadius) / _cell).floor();

    for (var r = minR; r <= maxR; r++) {
      for (var c = minC; c <= maxC; c++) {
        if (!level.isWall(c, r)) continue;
        final closest = Vector2(
          position.x.clamp(c * _cell, (c + 1) * _cell),
          position.y.clamp(r * _cell, (r + 1) * _cell),
        );
        final delta = position - closest;
        final dist = delta.length;
        if (dist >= _ballRadius || dist == 0) continue;

        final normal = delta / dist;
        position.add(normal * (_ballRadius - dist));
        final vn = _velocity.dot(normal);
        if (vn < 0) {
          _velocity.add(normal * (-vn * (1 + _restitution)));
          _bump(-vn);
        }
      }
    }
  }

  void _bump(double impact) {
    if (impact > 2.2 * _cell && _sinceLastBump > 0.15) {
      _sinceLastBump = 0;
      SoundService.instance.playMove();
      HapticFeedback.selectionClick();
    }
  }

  @override
  void render(Canvas canvas) {
    final centre = Offset(_ballRadius, _ballRadius);
    final r = _ballRadius * _scale;

    // Soft drop shadow under the ball.
    canvas.drawCircle(
      centre + Offset(0, _ballRadius * 0.18),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35 * _scale)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawCircle(
      centre,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          colors: [
            AppColors.secondaryFixed,
            AppColors.secondary,
            AppColors.secondaryContainer,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: centre, radius: r)),
    );

    // Specular highlight.
    canvas.drawCircle(
      centre + Offset(-r * 0.35, -r * 0.4),
      r * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.75 * _scale),
    );
  }
}

// ── Maze (floor, walls, holes) ───────────────────────────────────────────────

class _MazeComponent extends Component {
  final BallLevel level;

  _MazeComponent({required this.level});

  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final width = level.cols * _cell;
    final height = level.rows * _cell;

    // Floor.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        const Radius.circular(24),
      ),
      Paint()..color = AppColors.surfaceContainerLowest,
    );

    // Subtle dot grid on the floor, echoing PlayfulBackground.
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    for (var r = 1; r < level.rows; r++) {
      for (var c = 1; c < level.cols; c++) {
        if (level.isWall(c, r)) continue;
        canvas.drawCircle(
          Offset(c * _cell, r * _cell),
          1.6,
          dotPaint,
        );
      }
    }

    _renderStartPad(canvas);
    _renderHoles(canvas);
    _renderWalls(canvas);
  }

  void _renderStartPad(Canvas canvas) {
    final start = Offset(level.start.x * _cell, level.start.y * _cell);
    canvas.drawCircle(
      start,
      _ballRadius + 5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.14),
    );
  }

  void _renderHoles(Canvas canvas) {
    // Traps: dark pits with a danger rim.
    const lossColor = Color(0xFFFF6B6B);
    for (final trap in level.traps) {
      final centre = Offset(trap.x * _cell, trap.y * _cell);
      _renderPit(canvas, centre, _trapRadius, lossColor, rimWidth: 3);
    }

    // Goal: same pit, green rim with a slow pulsing glow.
    final goal = Offset(level.goal.x * _cell, level.goal.y * _cell);
    final pulse = 0.5 + 0.5 * math.sin(_time * 2 * math.pi / 1.6);
    canvas.drawCircle(
      goal,
      _goalRadius + 6 + pulse * 4,
      Paint()
        ..color = AppColors.tertiary.withValues(alpha: 0.18 + pulse * 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    _renderPit(canvas, goal, _goalRadius, AppColors.tertiary, rimWidth: 4);
  }

  void _renderPit(
    Canvas canvas,
    Offset centre,
    double radius,
    Color rim, {
    required double rimWidth,
  }) {
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.black, Colors.black.withValues(alpha: 0.75)],
        ).createShader(Rect.fromCircle(center: centre, radius: radius)),
    );
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rimWidth
        ..color = rim.withValues(alpha: 0.65),
    );
  }

  void _renderWalls(Canvas canvas) {
    final lipPaint = Paint()..color = const Color(0xFF001B55);
    final wallPaint = Paint()..color = AppColors.primaryContainer;
    final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.18);
    const radius = Radius.circular(10);
    const lip = 4.0;

    for (var r = 0; r < level.rows; r++) {
      for (var c = 0; c < level.cols; c++) {
        if (!level.isWall(c, r)) continue;
        // Slight inflation hides seams between adjacent wall tiles.
        final rect = Rect.fromLTWH(
          c * _cell,
          r * _cell,
          _cell,
          _cell,
        ).inflate(0.75);

        // 3-D lip: darker copy shifted down, playful-style.
        if (!level.isWall(c, r + 1)) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect.shift(const Offset(0, lip)), radius),
            lipPaint,
          );
        }
        canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), wallPaint);

        // Top-edge highlight on exposed tops.
        if (!level.isWall(c, r - 1)) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(rect.left + 4, rect.top + 2, rect.width - 8, 3),
              const Radius.circular(2),
            ),
            highlightPaint,
          );
        }
      }
    }
  }
}
