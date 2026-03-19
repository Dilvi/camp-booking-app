import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class BookingApiService {
  final DioClient _dioClient;

  BookingApiService(this._dioClient);

  Future<Map<String, dynamic>> createBooking({
    required int campId,
    required int childId,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.bookings,
      data: {
        'camp_id': campId,
        'child_id': childId,
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }
}