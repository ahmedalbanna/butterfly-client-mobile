/// Test configuration for integration tests
class TestConfig {
  /// API base URL for integration tests
  /// Override with environment variable: FLUTTER_TEST_API_URL
  static const String apiBaseUrl = String.fromEnvironment(
    'FLUTTER_TEST_API_URL',
    defaultValue: 'http://localhost:9002/api',
  );

  /// Test admin credentials
  static const String testAdminEmail = String.fromEnvironment(
    'FLUTTER_TEST_ADMIN_EMAIL',
    defaultValue: 'admin@luxury.com',
  );

  static const String testAdminPassword = String.fromEnvironment(
    'FLUTTER_TEST_ADMIN_PASSWORD',
    defaultValue: 'AdminPassword123!',
  );

  /// Test regular user credentials (non-admin)
  static const String testUserEmail = String.fromEnvironment(
    'FLUTTER_TEST_USER_EMAIL',
    defaultValue: 'user@luxury.com',
  );

  static const String testUserPassword = String.fromEnvironment(
    'FLUTTER_TEST_USER_PASSWORD',
    defaultValue: 'UserPassword123!',
  );

  /// Test timeout durations
  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration longTimeout = Duration(seconds: 30);

  /// Whether to run tests against real backend (true) or mocks (false)
  static const bool useRealBackend = bool.fromEnvironment(
    'FLUTTER_TEST_USE_REAL_BACKEND',
    defaultValue: false,
  );
}
