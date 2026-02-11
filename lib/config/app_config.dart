/// Admin application configuration constants
class AppConfig {
  static const String appName = 'LuxeFinds Admin';
  static const String appVersion = '0.1.0';
  
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:9002/api',
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
  static const String tokenStorageKey = 'admin_auth_token';
  static const String refreshTokenStorageKey = 'admin_refresh_token';
  static const String userStorageKey = 'admin_user_data';
}
