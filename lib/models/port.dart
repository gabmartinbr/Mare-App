class Port {
  final String id;
  final String name;
  final double lat;
  final double lon;

  Port({required this.id, required this.name, required this.lat, required this.lon});
}

List<Port> ports = [
  Port(id: '64', name: 'Granadilla (Tenerife)', lat: 28.088333, lon: -16.491667),
  Port(id: '65', name: 'Santa Cruz de Tenerife', lat: 28.463629, lon: -16.251846),
  // Puedes añadir más puertos aquí
];
