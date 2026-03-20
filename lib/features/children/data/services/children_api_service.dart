import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/child_model.dart';

class ChildrenApiService {
  final DioClient _dioClient;

  ChildrenApiService(this._dioClient);

  Future<List<ChildModel>> getChildren() async {
    final response = await _dioClient.get(ApiConstants.children);
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final list = data['data'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(ChildModel.fromJson)
            .toList();
      }
    }

    throw ApiException(
      message: 'Некорректный ответ сервера при получении детей',
      statusCode: response.statusCode,
    );
  }

  Future<ChildModel> createChild({
    required String? photoUrl,
    required String firstName,
    required String lastName,
    required String birthDate,
    required String gender,
    required String hobby,
    required String allergy,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.children,
      data: {
        'photo_url': photoUrl ?? '',
        'first_name': firstName,
        'last_name': lastName,
        'birth_date': birthDate,
        'gender': gender,
        'hobby': hobby,
        'allergy': allergy,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        return ChildModel.fromJson(nested);
      }
    }

    throw ApiException(
      message: 'Некорректный ответ сервера при добавлении ребёнка',
      statusCode: response.statusCode,
    );
  }

  Future<ChildModel> updateChild({
    required int childId,
    required String? photoUrl,
    required String firstName,
    required String lastName,
    required String birthDate,
    required String gender,
    required String hobby,
    required String allergy,
  }) async {
    final response = await _dioClient.put(
      ApiConstants.childById(childId),
      data: {
        'photo_url': photoUrl ?? '',
        'first_name': firstName,
        'last_name': lastName,
        'birth_date': birthDate,
        'gender': gender,
        'hobby': hobby,
        'allergy': allergy,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        return ChildModel.fromJson(nested);
      }
    }

    throw ApiException(
      message: 'Некорректный ответ сервера при редактировании ребёнка',
      statusCode: response.statusCode,
    );
  }

  Future<String> deleteChild(int childId) async {
    final response = await _dioClient.delete(ApiConstants.childById(childId));
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic> && nested['message'] != null) {
        return nested['message'].toString();
      }
    }

    throw ApiException(
      message: 'Некорректный ответ сервера при удалении ребёнка',
      statusCode: response.statusCode,
    );
  }
}