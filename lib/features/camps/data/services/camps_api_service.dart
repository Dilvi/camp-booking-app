import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class CampsApiService {
  final DioClient _dioClient;

  CampsApiService(this._dioClient);

  Future<List<dynamic>> getCamps() async {
    final response = await _dioClient.get(ApiConstants.camps);

    if (response.data is List) {
      return response.data as List<dynamic>;
    }

    return [];
  }
}