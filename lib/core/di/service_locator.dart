import '../network/dio_client.dart';
import '../../features/auth/data/services/auth_api_service.dart';
import '../../features/camps/data/services/camps_api_service.dart';
import '../../features/favorites/data/services/favorites_api_service.dart';
import '../../features/profile/data/services/profile_api_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final DioClient dioClient = DioClient();

  static final AuthApiService authApiService = AuthApiService(dioClient);
  static final CampsApiService campsApiService = CampsApiService(dioClient);
  static final FavoritesApiService favoritesApiService =
  FavoritesApiService(dioClient);
  static final ProfileApiService profileApiService = ProfileApiService(dioClient);
}