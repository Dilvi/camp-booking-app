import 'bike_route_model.dart';

class AiRouteAnalysisModel {
  final BikeRouteModel route;
  final String recommendations;

  const AiRouteAnalysisModel({
    required this.route,
    required this.recommendations,
  });

  factory AiRouteAnalysisModel.fromJson(Map<String, dynamic> json) {
    final routeJson = json['route'];
    return AiRouteAnalysisModel(
      route:
          routeJson is Map<String, dynamic>
              ? BikeRouteModel.fromJson(routeJson)
              : BikeRouteModel.fromJson(const <String, dynamic>{}),
      recommendations: (json['recommendations'] ?? '').toString(),
    );
  }
}
