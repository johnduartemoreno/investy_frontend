import 'dart:math' as math;
import 'package:flutter/material.dart';

enum OwlState { idle, thinking, celebrating }

/// Animated Owl AI mascot — pure Flutter, zero external deps.
///
/// Risk mitigations:
///   - RepaintBoundary isolates repaints to this widget only.
///   - All AnimationControllers disposed in dispose() — no leaks.
///   - Single AnimatedBuilder with Listenable.merge — one listener, no duplication.
///   - Blink scheduler checks `mounted` before each forward() call.
///   - CustomPainter uses `shouldRepaint` to skip unnecessary redraws.
class OwlAiWidget extends StatefulWidget {
  final double size;
  final OwlState state;

  const OwlAiWidget({
    super.key,
    this.size = 80,
    this.state = OwlState.idle,
  });

  @override
  State<OwlAiWidget> createState() => _OwlAiWidgetState();
}

class _OwlAiWidgetState extends State<OwlAiWidget>
    with TickerProviderStateMixin {
  // ── Controllers ─────────────────────────────────────────────
  late final AnimationController _breathCtrl;
  late final AnimationController _blinkCtrl;
  late final AnimationController _tieCtrl;
  late final AnimationController _thinkCtrl;
  late final AnimationController _celebrateCtrl;

  // ── Animations ───────────────────────────────────────────────
  late final Animation<double> _breathAnim;
  late final Animation<double> _blinkAnim;
  late final Animation<double> _tieAnim;
  late final Animation<double> _thinkAnim;
  late final Animation<double> _celebrateAnim;

  bool _disposed = false;

  @override
  void initState() {
    super.initState();

    // Breathing — body scale 1.0 → 1.04, 2s loop
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _breathAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut),
    );

    // Blinking — scaleY 1.0 → 0.08 → 1.0, fast snap
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _blinkAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.08), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.08, end: 1.0), weight: 60),
    ]).animate(_blinkCtrl);
    _scheduleBlink();

    // Tie wiggle — rotation ±5°, 1.8s loop
    _tieCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _tieAnim = Tween<double>(begin: -0.09, end: 0.09).animate(
      CurvedAnimation(parent: _tieCtrl, curve: Curves.easeInOut),
    );

    // Thinking bounce — up/down oscillation
    _thinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _thinkAnim = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(parent: _thinkCtrl, curve: Curves.easeInOut),
    );

    // Celebrate — scale pop + sparkles
    _celebrateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _celebrateAnim = CurvedAnimation(
      parent: _celebrateCtrl,
      curve: Curves.elasticOut,
    );

    _applyState(widget.state);
  }

  void _scheduleBlink() {
    // Random interval 3–5s so blinks feel natural
    final delay = 3000 + math.Random().nextInt(2000);
    Future.delayed(Duration(milliseconds: delay), () {
      if (_disposed || !mounted) return;
      _blinkCtrl.forward(from: 0.0).then((_) {
        if (_disposed || !mounted) return;
        _scheduleBlink();
      });
    });
  }

  void _applyState(OwlState state) {
    switch (state) {
      case OwlState.idle:
        _thinkCtrl.stop();
        _thinkCtrl.value = 0;
        break;
      case OwlState.thinking:
        _thinkCtrl.repeat(reverse: true);
        break;
      case OwlState.celebrating:
        _thinkCtrl.stop();
        _celebrateCtrl.forward(from: 0.0);
        break;
    }
  }

  @override
  void didUpdateWidget(OwlAiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _applyState(widget.state);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _breathCtrl.dispose();
    _blinkCtrl.dispose();
    _tieCtrl.dispose();
    _thinkCtrl.dispose();
    _celebrateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary: isolates repaints — scroll/parent rebuilds don't repaint owl
    return RepaintBoundary(
      child: AnimatedBuilder(
        // Single listener merges all animations — no duplicate rebuild subscriptions
        animation: Listenable.merge([
          _breathAnim,
          _blinkAnim,
          _tieAnim,
          _thinkAnim,
          _celebrateAnim,
        ]),
        builder: (context, _) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _OwlPainter(
              breathScale: _breathAnim.value,
              eyeScaleY: _blinkAnim.value,
              tieAngle: _tieAnim.value,
              thinkOffset: _thinkAnim.value,
              celebrateValue: _celebrateAnim.value,
              isThinking: widget.state == OwlState.thinking,
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CustomPainter
// All coordinates on a 64×64 grid, scaled by size/64.
// ─────────────────────────────────────────────────────────────
class _OwlPainter extends CustomPainter {
  final double breathScale;
  final double eyeScaleY;
  final double tieAngle;
  final double thinkOffset;
  final double celebrateValue;
  final bool isThinking;

  static const _brand = Color(0xFF6C63FF);
  static const _brandLight = Color(0xFFa78bfa);
  static const _dark = Color(0xFF1E1B2E);
  static const _beak = Color(0xFFfbbf24);

  const _OwlPainter({
    required this.breathScale,
    required this.eyeScaleY,
    required this.tieAngle,
    required this.thinkOffset,
    required this.celebrateValue,
    required this.isThinking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64.0;

    // Apply global translate for think bounce
    canvas.save();
    canvas.translate(0, thinkOffset * s);

    _drawBody(canvas, s);
    _drawEarTufts(canvas, s);
    _drawEyes(canvas, s);
    _drawBeak(canvas, s);
    _drawTie(canvas, s);

    canvas.restore();

    if (celebrateValue > 0) {
      _drawSparkles(canvas, size, celebrateValue);
    }
  }

  void _drawBody(Canvas canvas, double s) {
    final cx = 32 * s;
    final cy = 37 * s;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(breathScale);
    canvas.translate(-cx, -cy);

    // Body gradient fill
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 0.8,
        colors: [
          _brand.withValues(alpha: 0.45),
          _dark.withValues(alpha: 0.95),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(cx, cy),
        width: 48 * s,
        height: 44 * s,
      ));

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 44 * s, height: 40 * s),
      bodyPaint,
    );

    // Subtle inner glow rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * s
      ..color = _brand.withValues(alpha: 0.25);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 44 * s, height: 40 * s),
      rimPaint,
    );

    canvas.restore();
  }

  void _drawEarTufts(Canvas canvas, double s) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8 * s
      ..strokeCap = StrokeCap.round
      ..color = _brandLight;

    // Left tuft
    final leftPath = Path()
      ..moveTo(13 * s, 20 * s)
      ..cubicTo(8 * s, 8 * s, 12 * s, 4 * s, 18 * s, 10 * s);
    canvas.drawPath(leftPath, paint);

    // Right tuft
    final rightPath = Path()
      ..moveTo(51 * s, 20 * s)
      ..cubicTo(56 * s, 8 * s, 52 * s, 4 * s, 46 * s, 10 * s);
    canvas.drawPath(rightPath, paint);
  }

  void _drawEyes(Canvas canvas, double s) {
    _drawSingleEye(canvas, s, 22 * s, 27 * s);
    _drawSingleEye(canvas, s, 42 * s, 27 * s);
  }

  void _drawSingleEye(Canvas canvas, double s, double cx, double cy) {
    // Outer glow ring
    canvas.drawCircle(
      Offset(cx, cy),
      9 * s,
      Paint()..color = _brandLight.withValues(alpha: 0.08),
    );

    // Purple iris
    canvas.drawCircle(
      Offset(cx, cy),
      8 * s,
      Paint()..color = _brand,
    );

    // White sclera — blink applied via scaleY
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(1.0, eyeScaleY);
    canvas.translate(-cx, -cy);

    canvas.drawCircle(Offset(cx, cy), 5 * s, Paint()..color = Colors.white);

    // Pupil
    final pupilCx = cx + 1.5 * s;
    final pupilCy = cy - 1.5 * s;
    canvas.drawCircle(
      Offset(pupilCx, pupilCy),
      2.2 * s,
      Paint()..color = _dark,
    );

    // Highlight
    canvas.drawCircle(
      Offset(pupilCx + 1.5 * s, pupilCy - 1.5 * s),
      1.0 * s,
      Paint()..color = Colors.white,
    );

    // Thinking — half-closed lid
    if (isThinking) {
      canvas.drawRect(
        Rect.fromLTWH(cx - 5 * s, cy - 5 * s, 10 * s, 3.5 * s),
        Paint()..color = _dark,
      );
    }

    canvas.restore();
  }

  void _drawBeak(Canvas canvas, double s) {
    final path = Path()
      ..moveTo(32 * s, 33 * s)
      ..lineTo(28.5 * s, 37.5 * s)
      ..lineTo(35.5 * s, 37.5 * s)
      ..close();
    canvas.drawPath(path, Paint()..color = _beak);
  }

  void _drawTie(Canvas canvas, double s) {
    final cx = 32 * s;
    final tieTop = 44 * s;

    canvas.save();
    canvas.translate(cx, tieTop);
    canvas.rotate(tieAngle);
    canvas.translate(-cx, -tieTop);

    // Tie knot (trapezoid)
    final knotPath = Path()
      ..moveTo(29.5 * s, 44 * s)
      ..lineTo(34.5 * s, 44 * s)
      ..lineTo(33.5 * s, 49.5 * s)
      ..lineTo(30.5 * s, 49.5 * s)
      ..close();
    canvas.drawPath(knotPath, Paint()..color = _brandLight);

    // Tie body (diamond/arrow)
    final bodyPath = Path()
      ..moveTo(32 * s, 47 * s)
      ..lineTo(29.5 * s, 52 * s)
      ..lineTo(32 * s, 57 * s)
      ..lineTo(34.5 * s, 52 * s)
      ..close();
    canvas.drawPath(bodyPath, Paint()..color = _brand);

    canvas.restore();
  }

  void _drawSparkles(Canvas canvas, Size size, double t) {
    final s = size.width / 64.0;
    final paint = Paint();
    final positions = [
      Offset(8 * s, 22 * s),
      Offset(56 * s, 18 * s),
      Offset(6 * s, 48 * s),
      Offset(58 * s, 44 * s),
      Offset(16 * s, 8 * s),
      Offset(50 * s, 10 * s),
    ];
    final radii = [2.0, 1.5, 1.2, 1.8, 1.0, 1.4];
    final colors = [
      _brandLight,
      _brand,
      _brandLight,
      _brand,
      _brandLight,
      _brand
    ];

    for (var i = 0; i < positions.length; i++) {
      final alpha =
          (math.sin(t * math.pi) * (i.isEven ? 1.0 : 0.7)).clamp(0.0, 1.0);
      paint.color = colors[i].withValues(alpha: alpha);
      final radius = radii[i] * s * (0.5 + t * 0.8);
      canvas.drawCircle(positions[i], radius, paint);
    }
  }

  @override
  bool shouldRepaint(_OwlPainter old) =>
      old.breathScale != breathScale ||
      old.eyeScaleY != eyeScaleY ||
      old.tieAngle != tieAngle ||
      old.thinkOffset != thinkOffset ||
      old.celebrateValue != celebrateValue ||
      old.isThinking != isThinking;
}
