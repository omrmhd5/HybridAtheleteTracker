import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Circular progress ring — track + rounded mint arc with a centered child.
class ProgressRing extends StatelessWidget {
  final double size;
  final double stroke;
  final double pct; // 0..1
  final Color color;
  final Color track;
  final Widget? child;

  const ProgressRing({
    super.key,
    this.size = 78,
    this.stroke = 8,
    required this.pct,
    this.color = AppColors.primary,
    this.track = AppColors.surfaceLight,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: pct.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
            builder: (context, value, _) => CustomPaint(
              size: Size.square(size),
              painter: _RingPainter(
                pct: value,
                stroke: stroke,
                color: color,
                track: track,
              ),
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double pct;
  final double stroke;
  final Color color;
  final Color track;

  _RingPainter({
    required this.pct,
    required this.stroke,
    required this.color,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * pct,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.pct != pct || old.color != color || old.stroke != stroke;
}
