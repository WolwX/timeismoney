import 'package:flutter/material.dart';

/// A custom painter for a chronometer (stopwatch) icon with a number inside.
class ChronoIcon extends StatelessWidget {
  final int number; // 1 or 2
  final Color color; // gold or silver
  final double size;

  const ChronoIcon({
    Key? key,
    required this.number,
    required this.color,
    this.size = 36,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ChronoPainter(number, color),
      ),
    );
  }
}

class _ChronoPainter extends CustomPainter {
  final int number;
  final Color color;

  _ChronoPainter(this.number, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = size.width * 0.08;
    final Paint body = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final Paint outline = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    // Draw main circle (body)
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - stroke,
      body,
    );
    // Draw outline
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - stroke,
      outline,
    );
    // Draw top button (chronometer crown)
    final Paint crown = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    final double crownW = size.width * 0.22;
    final double crownH = size.height * 0.13;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.13),
          width: crownW,
          height: crownH,
        ),
        Radius.circular(crownH * 0.5),
      ),
      crown,
    );
    // Draw hands (optional, subtle)
    final Paint hand = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..strokeWidth = stroke * 0.7
      ..strokeCap = StrokeCap.round;
    // Minute hand
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width / 2, size.height * 0.28),
      hand,
    );
    // Hour hand
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width * 0.68, size.height * 0.44),
      hand,
    );
    // Draw number (1 or 2) in the center
    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size.width * 0.55,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 2,
              offset: Offset(1, 2),
            ),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
