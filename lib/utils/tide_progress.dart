import 'dart:math';
import 'package:flutter/material.dart';

class TideProgressWave extends StatefulWidget {
  final double progress; // 0.0 a 1.0
  final double width;
  final double height;

  const TideProgressWave({
    super.key,
    required this.progress,
    this.width = 150,
    this.height = 60,
  });

  @override
  _TideProgressWaveState createState() => _TideProgressWaveState();
}

class _TideProgressWaveState extends State<TideProgressWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(); // animación continua
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _WavePainter(
            progress: widget.progress,
            wavePhase: _controller.value * 2 * pi,
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress; // 0 a 1
  final double wavePhase;

  _WavePainter({required this.progress, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path = Path();
    final double waveHeight = 8.0;
    final double baseHeight = size.height * (1 - progress);

    path.moveTo(0, size.height);
    path.lineTo(0, baseHeight);

    for (double x = 0; x <= size.width; x++) {
      double y = waveHeight * sin(2 * pi * x / size.width + wavePhase) + baseHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}
