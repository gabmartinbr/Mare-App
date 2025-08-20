import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/ihm_service.dart';
import 'tide_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = false;

  void fetchNearestPortAndNavigate() async {
    setState(() => loading = true);

    Position? pos = await getCurrentLocation();
    if (pos == null) {
      setState(() => loading = false);
      return;
    }

    Map<String, dynamic>? nearestPort = await getNearestPort(pos);
    if (nearestPort == null) {
      setState(() => loading = false);
      return;
    }

    setState(() => loading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TidePage(portId: nearestPort['id']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mareas")),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: fetchNearestPortAndNavigate,
                child: const Text("Ver mareas"),
              ),
      ),
    );
  }
}
