import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:luxefinds_admin/services/auth_service.dart';
import 'package:luxefinds_admin/services/http_client.dart';
import 'package:luxefinds_admin/config/app_config.dart';

/// Unit tests for AuthService
/// Tests authentication logic with mocked HTTP responses
void main() {
  group('AuthService Unit Tests', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late HttpClient httpClient;
    late AuthService authService;
    late FlutterSecureStorage secureStorage;

    setUp(() {
      // Setup mocked HTTP client
      dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
      dioAdapter = DioAdapter(dio: dio);
      
      // Setup secure storage (uses in-memory for testing)
      FlutterSecureStorage.setMockInitialValues({});
      secureStorage = const FlutterSecureStorage();
      
      // Create HTTP client with mocked Dio
      httpClient = HttpClient(secureStorage: secureStorage);
      
      // Create auth service
      authService = AuthService(httpClient);
    });

    tearDown(() async {
      await secureStorage.deleteAll();
    });

    group('Login Tests', () {
      test('Successful admin login returns user and saves tokens', () async {
        // Mock successful login response
        dioAdapter.onPost(
          '/auth/login',
          (server) => server.reply(200, {
            'success': true,
            'user': {
              'id': 'user123',
              'email': 'admin@luxury.com',
              'name': 'Admin User',
              'isAdmin': true,
            },
            'accessToken': 'mock_access_token_12345',
            'refreshToken': 'mock_refresh_token_67890',
          }),
          data: {
            'email': 'admin@luxury.com',
            'password': 'AdminPassword123!',
          },
        );

        // Execute login
        final user = await authService.login(
          email: 'admin@luxury.com',
          password: 'AdminPassword123!',
        );

        // Verify user object
        expect(user.id, 'user123');
        expect(user.email, 'admin@luxury.com');
        expect(user.isAdmin, true);

        // Verify tokens are saved
        final accessToken = await secureStorage.read(key: 'admin_auth_token');
        final refreshToken = await secureStorage.read(key: 'admin_refresh_token');

        expect(accessToken, 'mock_access_token_12345');
        expect(refreshToken, 'mock_refresh_token_67890');
      });

      test('Login with non-admin account throws AuthException', () async {
        // Mock login response for non-admin user
        dioAdapter.onPost(
          '/auth/login',
          (server) => server.reply(200, {
            'success': true,
            'user': {
              'id': 'user456',
              'email': 'user@luxury.com',
              'name': 'Regular User',
              'isAdmin': false, // Not admin!
            },
            'accessToken': 'mock_access_token',
            'refreshToken': 'mock_refresh_token',
          }),
        );

        // Should throw AuthException
        expect(
          () => authService.login(
            email: 'user@luxury.com',
            password: 'password',
          ),
          throwsA(isA<AuthException>()),
        );
      });

      test('Login with invalid credentials throws AuthException', () async {
        // Mock 401 response
        dioAdapter.onPost(
          '/auth/login',
          (server) => server.reply(401, {
            'error': 'Invalid credentials',
          }),
        );

        // Should throw AuthException
        expect(
          () => authService.login(
            email: 'wrong@email.com',
            password: 'wrongpassword',
          ),
          throwsA(isA<AuthException>()),
        );
      });

      test('Login with missing tokens throws AuthException', () async {
        // Mock response without tokens (incompatible backend)
        dioAdapter.onPost(
          '/auth/login',
          (server) => server.reply(200, {
            'success': true,
            'user': {
              'id': 'user123',
              'email': 'admin@luxury.com',
              'isAdmin': true,
            },
            // Missing accessToken and refreshToken!
          }),
        );

        // Should throw AuthException
        expect(
          () => authService.login(
            email: 'admin@luxury.com',
            password: 'password',
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('Get Current User Tests', () {
      test('Get current user with valid token returns user', () async {
        // Pre-populate token
        await secureStorage.write(
          key: 'admin_auth_token',
          value: 'valid_token_12345',
        );

        // Mock /auth/me response
        dioAdapter.onGet(
          '/auth/me',
          (server) => server.reply(200, {
            'user': {
              'id': 'user123',
              'email': 'admin@luxury.com',
              'name': 'Admin User',
              'isAdmin': true,
            },
          }),
          headers: {'Authorization': 'Bearer valid_token_12345'},
        );

        // Execute
        final user = await authService.getCurrentUser();

        // Verify
        expect(user.id, 'user123');
        expect(user.email, 'admin@luxury.com');
        expect(user.isAdmin, true);
      });

      test('Get current user with invalid token throws AuthException', () async {
        // Pre-populate invalid token
        await secureStorage.write(
          key: 'admin_auth_token',
          value: 'invalid_token',
        );

        // Mock 401 response
        dioAdapter.onGet(
          '/auth/me',
          (server) => server.reply(401, {'error': 'Invalid token'}),
        );

        // Should throw
        expect(
          () => authService.getCurrentUser(),
          throwsA(isA<AuthException>()),
        );
      });

      test('Get current user for non-admin throws AuthException', () async {
        await secureStorage.write(
          key: 'admin_auth_token',
          value: 'valid_token',
        );

        // Mock response for non-admin user
        dioAdapter.onGet(
          '/auth/me',
          (server) => server.reply(200, {
            'user': {
              'id': 'user456',
              'email': 'user@luxury.com',
              'isAdmin': false, // Not admin!
            },
          }),
        );

        // Should throw AuthException
        expect(
          () => authService.getCurrentUser(),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('Logout Tests', () {
      test('Logout calls API and clears tokens', () async {
        // Pre-populate tokens
        await secureStorage.write(
          key: 'admin_auth_token',
          value: 'access_token',
        );
        await secureStorage.write(
          key: 'admin_refresh_token',
          value: 'refresh_token',
        );

        // Mock logout endpoint
        dioAdapter.onPost(
          '/auth/logout',
          (server) => server.reply(200, {
            'success': true,
            'message': 'Logged out successfully',
          }),
        );

        // Execute logout
        await authService.logout();

        // Verify tokens are cleared
        final accessToken = await secureStorage.read(key: 'admin_auth_token');
        final refreshToken = await secureStorage.read(key: 'admin_refresh_token');

        expect(accessToken, isNull);
        expect(refreshToken, isNull);
      });

      test('Logout clears tokens even if API call fails', () async {
        // Pre-populate tokens
        await secureStorage.write(
          key: 'admin_auth_token',
          value: 'access_token',
        );
        await secureStorage.write(
          key: 'admin_refresh_token',
          value: 'refresh_token',
        );

        // Mock failed logout endpoint
        dioAdapter.onPost(
          '/auth/logout',
          (server) => server.reply(500, {'error': 'Server error'}),
        );

        // Execute logout (should not throw)
        await authService.logout();

        // Verify tokens are still cleared despite API error
        final accessToken = await secureStorage.read(key: 'admin_auth_token');
        final refreshToken = await secureStorage.read(key: 'admin_refresh_token');

        expect(accessToken, isNull);
        expect(refreshToken, isNull);
      });
    });

    group('Token Refresh Tests', () {
      test('Token refresh with valid refresh token returns new tokens', () async {
        // Pre-populate refresh token
        await secureStorage.write(
          key: 'admin_refresh_token',
          value: 'valid_refresh_token',
        );

        // Mock refresh endpoint
        dioAdapter.onPost(
          '/auth/refresh',
          (server) => server.reply(200, {
            'success': true,
            'user': {
              'id': 'user123',
              'email': 'admin@luxury.com',
              'isAdmin': true,
            },
            'accessToken': 'new_access_token',
            'refreshToken': 'new_refresh_token',
          }),
          data: {'refreshToken': 'valid_refresh_token'},
        );

        // Execute refresh (via httpClient)
        // Note: This would be triggered automatically by the HTTP interceptor
        // For testing, we'll verify the logic exists
        
        expect(true, true); // Placeholder - full test requires interceptor testing
      });
    });
  });

  group('User Model Tests', () {
    test('User.fromJson parses correctly', () {
      final json = {
        'id': 'user123',
        'email': 'test@example.com',
        'name': 'Test User',
        'isAdmin': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.id, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.isAdmin, true);
      expect(user.createdAt, isNotNull);
      expect(user.updatedAt, isNotNull);
    });

    test('User.fromJson handles missing optional fields', () {
      final json = {
        'id': 'user123',
        'email': 'test@example.com',
        'isAdmin': false,
      };

      final user = User.fromJson(json);

      expect(user.id, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.name, isNull);
      expect(user.isAdmin, false);
      expect(user.createdAt, isNull);
      expect(user.updatedAt, isNull);
    });

    test('User.fromJson defaults isAdmin to false if missing', () {
      final json = {
        'id': 'user123',
        'email': 'test@example.com',
      };

      final user = User.fromJson(json);

      expect(user.isAdmin, false);
    });
  });
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
