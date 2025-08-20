import 'package:flutter/material.dart';
import 'dart:math' as math;

class TideCurve extends StatelessWidget {
  final double progress; // 0 = marea baja, 1 = marea alta

  const TideCurve({Key? key, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: CustomPaint(
        painter: _TideCurvePainter(progress),
      ),
    );
  }
}

class _TideCurvePainter extends CustomPainter {
  final double progress;

  _TideCurvePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paintCurve = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final h = size.height;
    final w = size.width;

    // Curva tipo seno simple (Poisson-like)
    path.moveTo(0, h); // empieza en marea baja
    for (double x = 0; x <= w; x++) {
      double y = h * 0.5 * (1 - math.sin((x / w) * 3.14159));
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paintCurve);

    // Punto que indica la posición actual de la marea
    double dotX = progress * w;
    double dotY = h * 0.5 * (1 - math.sin((dotX / w) * 3.14159));
    canvas.drawCircle(Offset(dotX, dotY), 6, paintDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
