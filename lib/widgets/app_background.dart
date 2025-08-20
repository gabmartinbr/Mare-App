import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        children: [
          // Mancha azul esquina superior izquierda
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.8, -0.8),
                radius: 0.8,
                colors: [
                  Color(0xFF003366),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Mancha cian esquina inferior derecha
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.8, 0.8),
                radius: 0.9,
                colors: [
                  Color(0xFF00FFFF),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Mancha azul suave en el centro
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, 0.2),
                radius: 1.0,
                colors: [
                  Color(0xFF004466),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          child, // 👈 contenido encima del fondo
        ],
      ),
    );
  }
}
