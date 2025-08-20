import 'package:geolocator/geolocator.dart';
import '../models/port.dart';
import 'dart:math';

class LocationHelper {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('GPS no habilitado');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw Exception('Permiso denegado');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  static Port findClosestPort(double myLat, double myLon) {
    ports.sort((a, b) => _distance(myLat, myLon, a.lat, a.lon)
        .compareTo(_distance(myLat, myLon, b.lat, b.lon)));
    return ports.first;
  }

  static double _distance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // km
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a = sin(dLat/2)*sin(dLat/2) +
               cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
               sin(dLon/2)*sin(dLon/2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    return R * c;
  }

  static double _deg2rad(double deg) => deg * (pi/180);
}
