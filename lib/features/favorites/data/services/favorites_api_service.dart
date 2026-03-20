import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../camps/data/models/camp_model.dart';

class FavoritesApiService {
  final DioClient _dioClient;

  FavoritesApiService(this._dioClient);

  Future<void> addToFavorites(int campId) async {
    await _dioClient.post(ApiConstants.favoriteByCampId(campId));
  }

  Future<void> removeFromFavorites(int campId) async {
    await _dioClient.delete(ApiConstants.favoriteByCampId(campId));
  }

  Future<List<CampModel>> getFavorites() async {
    final response = await _dioClient.get(ApiConstants.favorites);
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final list = data['data'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(
              (json) => CampModel.fromJson({
            ...json,
            'is_favorite': true,
          }),
        )
            .toList();
      }
    }

    throw ApiException(
      message: 'Некорректный ответ сервера при получении избранного',
      statusCode: response.statusCode,
    );
  }
}