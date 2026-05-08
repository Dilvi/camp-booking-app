class BikeRouteModel {
  final int id;
  final int campId;
  final String title;
  final String location;
  final String? mapUrl;
  final String routePoints;
  final double distanceKm;
  final int durationMinutes;
  final String difficulty;
  final String routeType;
  final int elevationGainM;
  final String description;

  const BikeRouteModel({
    required this.id,
    required this.campId,
    required this.title,
    required this.location,
    required this.mapUrl,
    required this.routePoints,
    required this.distanceKm,
    required this.durationMinutes,
    required this.difficulty,
    required this.routeType,
    required this.elevationGainM,
    required this.description,
  });

  factory BikeRouteModel.fromJson(Map<String, dynamic> json) {
    return BikeRouteModel(
      id: _asInt(json['id']),
      campId: _asInt(json['camp_id']),
      title: (json['title'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      mapUrl: json['map_url']?.toString(),
      routePoints: (json['route_points'] ?? '').toString(),
      distanceKm: _asDouble(json['distance_km']),
      durationMinutes: _asInt(json['duration_minutes']),
      difficulty: (json['difficulty'] ?? '').toString(),
      routeType: (json['route_type'] ?? '').toString(),
      elevationGainM: _asInt(json['elevation_gain_m']),
      description: (json['description'] ?? '').toString(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
