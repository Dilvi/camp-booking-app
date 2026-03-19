import '../network/dio_client.dart';
import '../network/health_api_service.dart';
import '../../features/auth/data/services/auth_api_service.dart';
import '../../features/booking/data/services/booking_api_service.dart';
import '../../features/camps/data/services/camps_api_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final DioClient dioClient = DioClient();

  static final AuthApiService authApiService = AuthApiService(dioClient);
  static final CampsApiService campsApiService = CampsApiService(dioClient);
  static final BookingApiService bookingApiService = BookingApiService(dioClient);
  static final HealthApiService healthApiService = HealthApiService(dioClient);
}