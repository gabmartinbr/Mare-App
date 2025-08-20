import 'package:flutter/material.dart';
import 'dart:math';

class TideCurveSpline extends StatelessWidget {
  final List<double> heights; // alturas normalizadas entre 0 y 1
  final double progress; // posición actual entre 0 y 1

  const TideCurveSpline({Key? key, required this.heights, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 150),
      painter: _TideCurveSplinePainter(heights, progress),
    );
  }
}

class _TideCurveSplinePainter extends CustomPainter {
  final List<double> heights;
  final double progress;

  _TideCurveSplinePainter(this.heights, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paintCurve = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final paintDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    if (heights.length < 2) return;

    final path = Path();

    // calcular coordenadas x y y
    List<Offset> points = [];
    for (int i = 0; i < heights.length; i++) {
      double x = i / (heights.length - 1) * size.width;
      double y = size.height * (1 - heights[i]);
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx, points[0].dy);

    // spline cúbica usando Path.cubicTo para cada segmento
    for (int i = 0; i < points.length - 1; i++) {
      Offset p0 = points[i];
      Offset p1 = points[i + 1];

      double controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(
        controlX, p0.dy,
        controlX, p1.dy,
        p1.dx, p1.dy,
      );
    }

    canvas.drawPath(path, paintCurve);

    // punto de progreso
    double dotX = progress * size.width;
    // aproximar Y por interpolación lineal simple
    int idx = (dotX / size.width * (points.length - 1)).floor();
    idx = min(idx, points.length - 2);
    double t = (dotX - points[idx].dx) / (points[idx + 1].dx - points[idx].dx);
    double dotY = points[idx].dy + (points[idx + 1].dy - points[idx].dy) * t;

    canvas.drawCircle(Offset(dotX, dotY), 6, paintDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
