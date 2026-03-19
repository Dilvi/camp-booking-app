class ApiConstants {
  static const String emulatorBaseUrl = 'http://10.0.2.2:8080';
  static const String baseUrl = emulatorBaseUrl;

  static const String health = '/health';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String camps = '/camps';
  static const String bookings = '/bookings';

  static String favoriteByCampId(int campId) => '/favorites/$campId';
}