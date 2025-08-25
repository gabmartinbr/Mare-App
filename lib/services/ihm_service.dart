import 'dart:convert';
import 'package:http/http.dart' as http;

class IhmService {
  static const String baseUrl = "https://ideihm.covam.es/api-ihm/getmarea";

  // Obtener la marea de un puerto en una fecha
  static Future<Map<String, dynamic>> getTide(String portId, String date) async {
    final url = "$baseUrl?request=gettide&id=$portId&format=json&date=$date";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return jsonData;
    } else {
      throw Exception("Error al obtener datos de marea");
    }
  }
}
