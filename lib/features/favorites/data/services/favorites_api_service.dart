import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class FavoritesApiService {
  final DioClient _dioClient;

  FavoritesApiService(this._dioClient);

  Future<void> addToFavorites(int campId) async {
    await _dioClient.post(ApiConstants.favoriteByCampId(campId));
  }

  Future<void> removeFromFavorites(int campId) async {
    await _dioClient.delete(ApiConstants.favoriteByCampId(campId));
  }
}