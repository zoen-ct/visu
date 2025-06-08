class ApiConfig {
  /// Base URL of the API
  static const String baseUrl = 'https://api.vizu.com';

  /// API endpoints
  static const String loginEndpoint = '/login';

  /// Key to store the authentication token in SharedPreferences
  static const String tokenKey = 'auth_token';

  /// Token expiration duration in days (useful for checking if the token has expired)
  static const int tokenExpirationDays = 30;
}
