// lib/screens/tide_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/port.dart';
import '../services/ihm_service.dart';
import '../services/location_service.dart';
import '../services/ports_list.dart';
import 'app_background.dart';

class TidePage extends StatefulWidget {
  const TidePage({super.key});

  @override
  _TidePageState createState() => _TidePageState();
}

class _TidePageState extends State<TidePage> {
  Map<String, dynamic>? tideData;
  List<Map<String, dynamic>> mareaList = [];
  bool loading = true;
  late PageController _pageController;
  int nextIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTide();
  }

  @override
  void dispose() {
    // Si se creó el PageController, liberarlo
    try {
      _pageController.dispose();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _loadTide() async {
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();
      final lat = position.latitude;
      final lon = position.longitude;

      final nearestPort = _getNearestPort(lat, lon);
      final today = DateFormat('yyyyMMdd').format(DateTime.now());
      final tide = await IhmService.getTide(nearestPort.id.toString(), today);

      final now = DateTime.now();
      final List<dynamic> mareaRaw = tide['mareas']['datos']['marea'];
      mareaList = mareaRaw.map((e) => Map<String, dynamic>.from(e)).toList();

      // calcular índice de la siguiente marea (la primera marea cuya hora +1h es posterior a now)
      nextIndex = 0;
      for (int i = 0; i < mareaList.length; i++) {
        final parts = mareaList[i]['hora'].toString().split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final mHora = DateTime(now.year, now.month, now.day, hour, minute)
            .add(const Duration(hours: 1));
        if (mHora.isAfter(now)) {
          nextIndex = i;
          break;
        }
      }

      setState(() {
        tideData = tide;
        loading = false;
        _pageController = PageController(
          initialPage: nextIndex,
          viewportFraction: 0.35,
        );
      });
    } catch (e) {
      print("Error al cargar la marea: $e");
      setState(() {
        loading = false;
      });
    }
  }

  Port _getNearestPort(double lat, double lon) {
    double minDistance = double.infinity;
    Port? nearest;

    for (var port in portList) {
      final distance = _calculateDistance(lat, lon, port.lat, port.lon);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = port;
      }
    }
    return nearest!;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

// Función que devuelve el color según la marea
Color _getWaterIconColor() {
  if (mareaList.isEmpty) return Colors.white.withOpacity(0.4);

  final now = DateTime.now();

  for (var i = 0; i < mareaList.length; i++) {
    final m = mareaList[i];
    final parts = m['hora'].toString().split(':');
    final mTime = DateTime(
            now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]))
        .add(const Duration(hours: 1));

    if (mTime.isAfter(now)) {
      final tipo = m['tipo'].toString().toLowerCase();
      return tipo.contains('alta') ? const Color.fromARGB(255, 76, 175, 145) : const Color.fromARGB(255, 243, 115, 106);
    }
  }
  return Colors.white.withOpacity(0.4);
}

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "MareApp",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w100,
              color: Colors.white,
            ),
          ),
          iconTheme:
              const IconThemeData(color: Color.fromARGB(255, 122, 188, 197)),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : tideData == null
                ? const Center(
                    child:
                        Text("No se pudo cargar la marea", style: TextStyle(color: Colors.white)))
                : Column(
                    children: [
                      const SizedBox(height: 20),
                      Text("Puerto más cercano: ${tideData!['mareas']['puerto']}",
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w100,
                              color: Colors.blueGrey)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 110,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: mareaList.length,
                          itemBuilder: (context, index) {
                            final m = mareaList[index];
                            final horaParts = m['hora'].toString().split(':');
                            final now = DateTime.now();
                            final hora = DateTime(now.year, now.month, now.day,
                                    int.parse(horaParts[0]), int.parse(horaParts[1]))
                                .add(const Duration(hours: 1));
                            final tipo = m['tipo'];
                            final altura = m['altura'];

                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double value = 1.0;
                                if (_pageController.hasClients) {
                                  if (_pageController.page != null) {
                                    value = _pageController.page! - index;
                                  } else {
                                    value = (_pageController.initialPage - index).toDouble();
                                  }
                                  value = (1 - (value.abs() * 0.5)).clamp(0.0, 1.0);
                                }

                                return Center(
                                  child: Transform.scale(
                                    scale: Curves.easeOut.transform(value),
                                    child: Opacity(
                                      opacity: (0.4 + 0.6 * value).clamp(0.3, 1.0),
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                color:
                                    const Color.fromARGB(255, 105, 196, 245).withOpacity(0.25),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(tipo,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Color.fromARGB(255, 230, 231, 233))),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Color.fromARGB(255, 230, 231, 233)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text("Altura: $altura m",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Color.fromARGB(255, 148, 174, 188))),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.water,
                            size: 48,
                            color: _getWaterIconColor(), // Verde = marea alta, Rojo = marea baja
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _getWaterIconColor() == Colors.green
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: _getWaterIconColor(),
                            size: 32,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 140,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: CustomPaint(
                            painter: TideProgressCurvePainter(
                              mareaList: mareaList,
                              now: DateTime.now(),
                              nextIndex: nextIndex,
                            ),
                            child: Container(),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class TideProgressCurvePainter extends CustomPainter {
  final List<Map<String, dynamic>> mareaList;
  final DateTime now;
  final int nextIndex;

  TideProgressCurvePainter({
    required this.mareaList,
    required this.now,
    required this.nextIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (mareaList.isEmpty) return;

    // calcular índices prev/next de forma segura (circular)
    final int nextIdx = nextIndex.clamp(0, mareaList.length - 1);
    final int prevIdx = (nextIdx - 1 + mareaList.length) % mareaList.length;

    final prevMarea = mareaList[prevIdx];
    final nextMarea = mareaList[nextIdx];

    final prevAltura = double.tryParse(prevMarea['altura'].toString()) ?? 0.0;
    final nextAltura = double.tryParse(nextMarea['altura'].toString()) ?? 0.0;

    // parsear horas (+1h si usas ese ajuste)
    final prevParts = prevMarea['hora'].toString().split(':');
    final nextParts = nextMarea['hora'].toString().split(':');
    DateTime prevTime = DateTime(now.year, now.month, now.day,
            int.parse(prevParts[0]), int.parse(prevParts[1]))
        .add(const Duration(hours: 1));
    DateTime nextTime = DateTime(now.year, now.month, now.day,
            int.parse(nextParts[0]), int.parse(nextParts[1]))
        .add(const Duration(hours: 1));

    // si cruza medianoche
    if (nextTime.isBefore(prevTime)) nextTime = nextTime.add(const Duration(days: 1));

    // progreso entre prev y next
    final totalDuration = nextTime.difference(prevTime).inMinutes;
    final elapsed = now.difference(prevTime).inMinutes.clamp(0, totalDuration);
    final progress = totalDuration > 0 ? elapsed / totalDuration : 0.0;

    // coordenadas en canvas (y0 inicio, y1 fin)
    final double y0 = size.height - (prevAltura / 2.5) * size.height;
    final double y1 = size.height - (nextAltura / 2.5) * size.height;

    final double cx = size.width / 2;
    final double curveOffset = size.height * 0.2; // ajusta la pronunciación
    final double cy = ((y0 + y1) / 2) + (nextAltura > prevAltura ? -curveOffset : curveOffset);

    // path de la curva completa (sólo trazo)
    final Path curvePath = Path();
    curvePath.moveTo(0, y0);
    curvePath.quadraticBezierTo(cx, cy, size.width, y1);

    // dibujar la curva
    final Paint curvePaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(curvePath, curvePaint);

    // Si hay progreso (>0) construimos y pintamos el bloque recortado por la curva
    if (progress > 0) {
      const int samples = 64;
      final List<Offset> sampled = <Offset>[];

      for (int i = 0; i <= samples; i++) {
        final double t = (i / samples) * progress;
        final double x = (1 - t) * (1 - t) * 0 + 2 * (1 - t) * t * cx + t * t * size.width;
        final double y = (1 - t) * (1 - t) * y0 + 2 * (1 - t) * t * cy + t * t * y1;
        sampled.add(Offset(x, y));
      }

      // construir polígono:
      final Path fillPath = Path();
      fillPath.moveTo(0, size.height);      // base izquierda
      fillPath.lineTo(0, y0);               // subir vertical hasta inicio rampa
      for (final p in sampled) {
        fillPath.lineTo(p.dx, p.dy);       // seguir la curva muestreada hasta el punto
      }
      final Offset last = sampled.last;
      fillPath.lineTo(last.dx, size.height); // bajar vertical hasta base en última x
      fillPath.close();

      // pintar relleno oscuro (izquierda/progreso)
      final Paint fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color.fromARGB(255, 22, 227, 217).withOpacity(0.5),
            const Color.fromARGB(255, 140, 1, 227).withOpacity(0.3)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);

      // Dibujar línea vertical desde el punto hasta la base
      final Offset point = last;
      canvas.drawLine(
        point,
        Offset(point.dx, size.height),
        Paint()
          ..color = Colors.white.withOpacity(0.95)
          ..strokeWidth = 1.6,
      );

      // BURBUJA AZUL TRANSLÚCIDA (recomendada) con borde blanco
      canvas.drawCircle(point, 4.0, Paint()..color = const Color.fromARGB(255, 255, 255, 255).withOpacity(1)); // relleno
      canvas.drawCircle(point, 4.0, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withOpacity(0.95)); // borde
    }

    // base fina para contraste
    canvas.drawLine(
      const Offset(0, 0).translate(0, size.height),
      Offset(size.width, size.height),
      Paint()..color = Colors.white.withOpacity(0.06),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

