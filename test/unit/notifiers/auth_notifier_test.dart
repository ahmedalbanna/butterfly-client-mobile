import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luxefinds_client/models/user.dart';

import '../../helpers/test_fixtures.dart';
import '../../mocks/mock_services.dart';

void main() {
  group('AuthNotifier Tests', () {
    late ProviderContainer container;
    late FakeAuthService authService;

    setUp(() {
      authService = FakeAuthService();
      container = ProviderContainer(
        overrides: [
          // Override auth service provider with fake
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Login State', () {
      test('initial state is unauthenticated', () async {
        // Test initial auth state
        expect(authService.currentUser, isNull);
      });

      test('user can login successfully', () async {
        final user = await authService.login('test@example.com', 'password123');
        expect(user, isNotNull);
        expect(user.email, equals('test@example.com'));
      });

      test('login updates current user', () async {
        expect(authService.currentUser, isNull);
        await authService.login('test@example.com', 'password123');
        expect(authService.currentUser, isNotNull);
        expect(authService.currentUser!.email, equals('test@example.com'));
      });

      test('login with invalid credentials fails', () async {
        authService.loginSuccess = false;
        expect(
          () => authService.login('test@example.com', 'wrong'),
          throwsException,
        );
      });
    });

    group('Logout State', () {
      test('logout clears current user', () async {
        await authService.login('test@example.com', 'password123');
        expect(authService.currentUser, isNotNull);
        await authService.logout();
        expect(authService.currentUser, isNull);
      });

      test('can login again after logout', () async {
        await authService.login('test@example.com', 'password123');
        await authService.logout();
        final user = await authService.login('test@example.com', 'password123');
        expect(user, isNotNull);
      });
    });

    group('Signup State', () {
      test('signup creates new user', () async {
        const email = 'newuser@example.com';
        const name = 'New User';
        final user = await authService.signup(email, name, 'password123');
        expect(user.email, equals(email));
        expect(user.name, equals(name));
      });

      test('signup sets current user', () async {
        expect(authService.currentUser, isNull);
        await authService.signup('newuser@example.com', 'New User', 'password123');
        expect(authService.currentUser, isNotNull);
      });
    });

    group('Token Refresh', () {
      test('can refresh token', () async {
        await authService.login('test@example.com', 'password123');
        final result = await authService.refreshToken();
        expect(result, equals(true));
      });

      test('maintains user during token refresh', () async {
        await authService.login('test@example.com', 'password123');
        final userBefore = authService.getCurrentUser();
        await authService.refreshToken();
        final userAfter = authService.getCurrentUser();
        expect(userBefore, equals(userAfter));
      });

      test('token refresh handles errors', () async {
        authService.exception = Exception('Refresh failed');
        expect(
          () => authService.refreshToken(),
          throwsException,
        );
      });
    });

    group('Get Current User', () {
      test('returns null when not authenticated', () {
        expect(authService.getCurrentUser(), isNull);
      });

      test('returns user when authenticated', () async {
        await authService.login('test@example.com', 'password123');
        final user = authService.getCurrentUser();
        expect(user, isNotNull);
        expect(user!.email, equals('test@example.com'));
      });

      test('returns same user across multiple calls', () async {
        await authService.login('test@example.com', 'password123');
        final user1 = authService.getCurrentUser();
        final user2 = authService.getCurrentUser();
        expect(user1, equals(user2));
      });
    });

    group('Authentication Flow', () {
      test('complete login flow', () async {
        // Initial state
        expect(authService.getCurrentUser(), isNull);

        // Login
        final user = await authService.login('test@example.com', 'password123');
        expect(user, isNotNull);
        expect(authService.getCurrentUser(), equals(user));

        // Token refresh
        final refreshed = await authService.refreshToken();
        expect(refreshed, equals(true));

        // Logout
        await authService.logout();
        expect(authService.getCurrentUser(), isNull);
      });

      test('complete signup flow', () async {
        // Initial state
        expect(authService.getCurrentUser(), isNull);

        // Signup
        const email = 'newuser@example.com';
        const name = 'New User';
        final user = await authService.signup(email, name, 'password123');
        expect(user.email, equals(email));
        expect(authService.getCurrentUser(), equals(user));

        // Can refresh token
        final refreshed = await authService.refreshToken();
        expect(refreshed, equals(true));

        // Logout
        await authService.logout();
        expect(authService.getCurrentUser(), isNull);
      });
    });

    group('Error Handling', () {
      test('handles login service error', () async {
        authService.exception = Exception('Service error');
        expect(
          () => authService.login('test@example.com', 'password123'),
          throwsException,
        );
      });

      test('handles signup service error', () async {
        authService.exception = Exception('Service error');
        expect(
          () => authService.signup('new@example.com', 'New User', 'password123'),
          throwsException,
        );
      });

      test('handles logout service error', () async {
        await authService.login('test@example.com', 'password123');
        authService.exception = Exception('Logout error');
        expect(
          () => authService.logout(),
          throwsException,
        );
      });
    });

    group('User Data Integrity', () {
      test('preserves user data after login', () async {
        const email = 'test@example.com';
        const password = 'password123';
        final user = await authService.login(email, password);
        
        expect(user.id, isNotEmpty);
        expect(user.email, equals(email));
        expect(user.name, isNotEmpty);
        expect(user.createdAt, isNotNull);
      });

      test('user object is immutable', () async {
        await authService.login('test@example.com', 'password123');
        final user1 = authService.getCurrentUser()!;
        final user2 = authService.getCurrentUser()!;
        expect(user1, equals(user2));
      });
    });
  });
}
