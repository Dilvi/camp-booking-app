import '../constants/api_constants.dart';
import 'dio_client.dart';

class HealthApiService {
  final DioClient _dioClient;

  HealthApiService(this._dioClient);

  Future<Map<String, dynamic>> checkHealth() async {
    final response = await _dioClient.get(ApiConstants.health);

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }

    return {'status': 'unknown'};
  }
}