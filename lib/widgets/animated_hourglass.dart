import 'package:flutter/material.dart';

/// A simple hourglass painter with animated sand level.
class AnimatedHourglass extends StatelessWidget {
  /// progress from 0.0 (all sand top) to 1.0 (all sand bottom)
  final double progress;
  final Color sandColor;
  final Color outlineColor;
  final double size;

  const AnimatedHourglass({
    Key? key,
    required this.progress,
    this.sandColor = const Color(0xFFFFD54F),
    this.outlineColor = Colors.white54,
    this.size = 150,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HourglassPainter(progress.clamp(0.0, 1.0), sandColor, outlineColor),
      ),
    );
  }
}

class _HourglassPainter extends CustomPainter {
  final double progress;
  final Color sandColor;
  final Color outlineColor;

  _HourglassPainter(this.progress, this.sandColor, this.outlineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paintOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..color = outlineColor
      ..strokeCap = StrokeCap.round;

    final paintSand = Paint()..color = sandColor;

    final w = size.width;
    final h = size.height;

    // Draw the glass outline as two curved bulbs connected by a neck
    final path = Path();
    // Top bulb (left side)
    path.moveTo(w * 0.2, h * 0.15);
    path.quadraticBezierTo(w * 0.5, h * 0.22, w * 0.8, h * 0.15);
    // down right to neck
    path.lineTo(w * 0.6, h * 0.5 - h * 0.03);
    // bottom bulb right curve
    path.quadraticBezierTo(w * 0.5, h * 0.78, w * 0.8, h * 0.85);
    // bottom right to left
    path.lineTo(w * 0.2, h * 0.85);
    path.quadraticBezierTo(w * 0.5, h * 0.78, w * 0.4, h * 0.5 + h * 0.03);
    path.lineTo(w * 0.2, h * 0.15);

    canvas.drawPath(path, paintOutline);

    // Draw sand top (invert progress)
    final topProgress = (1.0 - progress).clamp(0.0, 1.0);
    if (topProgress > 0.0) {
      // Top sand area: a curved trapezoid inside top bulb
      final topPath = Path();
      final topHeight = h * 0.25 * topProgress + h * 0.02;
      topPath.moveTo(w * 0.22, h * 0.17 + (h * 0.0));
      topPath.quadraticBezierTo(w * 0.5, h * 0.15 + topHeight, w * 0.78, h * 0.17);
      topPath.lineTo(w * 0.78, h * 0.15 + 0.02);
      topPath.quadraticBezierTo(w * 0.5, h * 0.15 + topHeight * 0.9, w * 0.22, h * 0.15 + 0.02);
      topPath.close();
      canvas.drawPath(topPath, paintSand);
    }

    // Draw sand bottom
    if (progress > 0.0) {
      final bottomPath = Path();
      final bottomHeight = h * 0.25 * progress + h * 0.02;
      bottomPath.moveTo(w * 0.22, h * 0.83);
      bottomPath.quadraticBezierTo(w * 0.5, h * 0.85 - bottomHeight, w * 0.78, h * 0.83);
      bottomPath.lineTo(w * 0.78, h * 0.85);
      bottomPath.lineTo(w * 0.22, h * 0.85);
      bottomPath.close();
      canvas.drawPath(bottomPath, paintSand);
    }

    // Draw falling sand line in the neck if in motion
    if (progress > 0.0 && progress < 1.0) {
      final cx = w * 0.5;
      final y1 = h * 0.42;
      final y2 = h * 0.58;
      final fallPaint = Paint()
        ..color = sandColor.withAlpha((0.95 * 255).round())
        ..strokeWidth = w * 0.012
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx, y1), Offset(cx, y2), fallPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HourglassPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.sandColor != sandColor || oldDelegate.outlineColor != outlineColor;
  }
}
