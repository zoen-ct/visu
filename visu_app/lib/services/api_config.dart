class ApiConfig {
  /// Base URL of the API
  static const String baseUrl = 'https://api.vizu.com';

  /// API endpoints
  static const String loginEndpoint = '/login';

  /// Key to store the authentication token in SharedPreferences
  static const String tokenKey = 'auth_token';

  /// Token expiration duration in days (useful for checking if the token has expired)
  static const int tokenExpirationDays = 30;

  static const String tmdbApiKey = 'c293614147b5386b2a7d6d974432e25b';
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  // Available image sizes
  static const String posterSize = 'w500';
  static const String backdropSize = 'w1280';
  static const String profileSize = 'w185';
}
