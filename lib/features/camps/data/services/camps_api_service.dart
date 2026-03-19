import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/camp_model.dart';

class CampsApiService {
  final DioClient _dioClient;

  CampsApiService(this._dioClient);

  Future<List<CampModel>> getCamps() async {
    final response = await _dioClient.get(ApiConstants.camps);
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final list = data['data'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(CampModel.fromJson)
            .toList();
      }
    }

    throw ApiException(
      message: 'Некорректный ответ сервера при получении лагерей',
      statusCode: response.statusCode,
    );
  }
}