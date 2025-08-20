import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

Future<Position?> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return null;
  }
  if (permission == LocationPermission.deniedForever) return null;

  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

Future<Map<String, dynamic>?> getNearestPort(Position userPos) async {
  final url = Uri.parse(
      "https://ideihm.covam.es/api-ihm/getpuertos?request=getports&format=json");

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> ports = data['puertos'];

      Map<String, dynamic>? nearest;
      double minDistance = double.infinity;

      for (var port in ports) {
        double lat = double.parse(port['lat']);
        double lon = double.parse(port['lon']);
        double distance = Geolocator.distanceBetween(
            userPos.latitude, userPos.longitude, lat, lon);
        if (distance < minDistance) {
          minDistance = distance;
          nearest = port;
        }
      }

      return nearest;
    }
  } catch (e) {
    print("Error al obtener puertos: $e");
  }

  return null;
}
