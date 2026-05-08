import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/ai_route_analysis_model.dart';
import '../models/bike_route_model.dart';
import '../models/booking_model.dart';

class BookingApiService {
  final DioClient _dioClient;

  BookingApiService(this._dioClient);

  Future<BookingModel> createBooking({
    required int campId,
    required int childId,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.bookings,
      data: {'camp_id': campId, 'child_id': childId},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        return BookingModel.fromJson(nested);
      }
    }

    throw ApiException(
      message: 'Некорректный ответ сервера при создании брони',
      statusCode: response.statusCode,
    );
  }

  Future<List<BookingModel>> getBookings() async {
    final response = await _dioClient.get(ApiConstants.bookings);
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final list = data['data'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(BookingModel.fromJson)
            .toList();
      }
    }

    throw ApiException(
      message: 'Некорректный ответ сервера при получении броней',
      statusCode: response.statusCode,
    );
  }

  Future<BookingModel> getBooking(int bookingId) async {
    final response = await _dioClient.get(ApiConstants.bookingById(bookingId));
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        return BookingModel.fromJson(nested);
      }
    }

    throw ApiException(
      message: 'Некорректный ответ сервера при получении брони',
      statusCode: response.statusCode,
    );
  }

  Future<List<BikeRouteModel>> getBikeRoutes(int bookingId) async {
    final response = await _dioClient.get(
      ApiConstants.bikeRoutesByBookingId(bookingId),
    );
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final list = data['data'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(BikeRouteModel.fromJson)
            .toList();
      }
    }

    throw ApiException(
      message: 'Некорректный ответ сервера при получении веломаршрутов',
      statusCode: response.statusCode,
    );
  }

  Future<AiRouteAnalysisModel> analyzeBikeRoute({
    required int bookingId,
    required int routeId,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.bikeRouteAnalysis(bookingId: bookingId, routeId: routeId),
    );
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        return AiRouteAnalysisModel.fromJson(nested);
      }
    }

    throw ApiException(
      message: 'Некорректный ответ сервера при получении ИИ-рекомендации',
      statusCode: response.statusCode,
    );
  }
}
