import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/profile_model.dart';

class ProfileApiService {
  final DioClient _dioClient;

  ProfileApiService(this._dioClient);

  Future<ProfileModel> getProfile() async {
    final response = await _dioClient.get(ApiConstants.profile);
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        return ProfileModel.fromJson(nested);
      }
    }

    throw ApiException(
      message: 'Некорректный ответ сервера при получении профиля',
      statusCode: response.statusCode,
    );
  }

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _dioClient.put(
      ApiConstants.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic> && nested['message'] != null) {
        return nested['message'].toString();
      }
    }

    throw ApiException(
      message: 'Некорректный ответ сервера при смене пароля',
      statusCode: response.statusCode,
    );
  }
}