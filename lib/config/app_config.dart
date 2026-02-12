/// Application configuration constants
class AppConfig {
  static const String appName = 'LuxeFinds';
  static const String appVersion = '0.1.0';
  
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://3000-01kg82wsgx3wam97rd4g74d1h5.cloudspaces.litng.ai/api',
  );
  
  // Request timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache settings
  static const Duration cacheExpiration = Duration(hours: 1);
  
  // Storage keys
  static const String tokenStorageKey = 'auth_token';
  static const String refreshTokenStorageKey = 'refresh_token';
  static const String userStorageKey = 'user_data';
  static const String cartStorageKey = 'cart_data';
}
