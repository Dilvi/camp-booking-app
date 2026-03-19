import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';

class AuthApiService {
  final DioClient _dioClient;

  AuthApiService(this._dioClient);

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic> && nestedData['token'] != null) {
        return nestedData['token'].toString();
      }
    }

    throw ApiException(
      message: 'Токен не найден в ответе сервера',
      statusCode: response.statusCode,
    );
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.register,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
        'password': password,
      },
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic>) {
        return nestedData;
      }
    }

    throw ApiException(
      message: 'Некорректный ответ сервера при регистрации',
      statusCode: response.statusCode,
    );
  }
}