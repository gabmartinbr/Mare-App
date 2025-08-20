import 'package:flutter/material.dart';
import '../models/location_helper.dart';
import '../services/ihm_service.dart';

class TidePage extends StatefulWidget {
  const TidePage({super.key});

  @override
  State<TidePage> createState() => _TidePageState();
}

class _TidePageState extends State<TidePage> {
  Map<String, dynamic>? tideData;
  bool loading = true;
  String? puertoName;

  @override
  void initState() {
    super.initState();
    loadTides();
  }

  Future<void> loadTides() async {
    setState(() => loading = true);
    try {
      final pos = await LocationHelper.getCurrentLocation();
      final port = LocationHelper.findClosestPort(pos.latitude, pos.longitude);

      final data = await IhmService().fetchTideDay(port.id);

      setState(() {
        tideData = data;
        puertoName = port.name;
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (tideData == null) return const Center(child: Text('No se pudieron cargar las mareas'));

    final List<dynamic> mareas = tideData!['datos']['marea'];

    return Scaffold(
      appBar: AppBar(title: Text(puertoName ?? 'Puerto')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mareas.length,
        itemBuilder: (context, index) {
          final marea = mareas[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(
                marea['tipo'] == 'pleamar' ? Icons.arrow_upward : Icons.arrow_downward,
                color: marea['tipo'] == 'pleamar' ? Colors.blue : Colors.orange,
              ),
              title: Text('Hora: ${marea['hora']}'),
              subtitle: Text('Altura: ${marea['altura']} m - Tipo: ${marea['tipo']}'),
            ),
          );
        },
      ),
    );
  }
}
