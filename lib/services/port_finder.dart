import 'dart:math';
import '../models/port.dart';
import 'ports_list.dart';
import 'package:geolocator/geolocator.dart';

class PortFinder {
  // Calcula el puerto más cercano según la ubicación
  Port getClosestPort(Position position) {
    double minDistance = double.infinity;
    Port? closestPort;

    for (var port in portList) {
      final distance = _distance(
        position.latitude,
        position.longitude,
        port.lat,
        port.lon,
      );
      if (distance < minDistance) {
        minDistance = distance;
        closestPort = port;
      }
    }

    if (closestPort == null) throw Exception('No se encontró ningún puerto.');
    return closestPort;
  }

  // Distancia en km usando fórmula de Haversine
  double _distance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = 
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }
}
