import 'package:flutter_test/flutter_test.dart';
import 'package:luxefinds_client/models/user.dart';
import 'package:luxefinds_client/services/auth_service.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/test_fixtures.dart';
import '../../mocks/mock_services.dart';

void main() {
  group('AuthService Tests', () {
    late FakeAuthService authService;

    setUp(() {
      authService = FakeAuthService();
    });

    group('Login', () {
      test('successfully logs in with valid credentials', () async {
        final user = await authService.login('test@example.com', 'password123');
        expect(user, isNotNull);
        expect(user.email, equals('test@example.com'));
        expect(authService.currentUser, equals(user));
      });

      test('sets current user after successful login', () async {
        expect(authService.currentUser, isNull);
        await authService.login('test@example.com', 'password123');
        expect(authService.currentUser, isNotNull);
      });

      test('throws exception on login failure', () async {
        authService.loginSuccess = false;
        expect(
          () => authService.login('test@example.com', 'password123'),
          throwsException,
        );
      });

      test('throws exception when service error occurs', () async {
        authService.exception = Exception('Network error');
        expect(
          () => authService.login('test@example.com', 'password123'),
          throwsException,
        );
      });

      test('login returns user with correct email', () async {
        const email = 'user@example.com';
        final user = await authService.login(email, 'password');
        expect(user.email, equals(email));
      });
    });

    group('Signup', () {
      test('successfully signs up new user', () async {
        const email = 'newuser@example.com';
        const name = 'New User';
        final user = await authService.signup(email, name, 'password123');
        expect(user, isNotNull);
        expect(user.email, equals(email));
        expect(user.name, equals(name));
      });

      test('sets current user after successful signup', () async {
        expect(authService.currentUser, isNull);
        await authService.signup('new@example.com', 'New User', 'password123');
        expect(authService.currentUser, isNotNull);
      });

      test('throws exception on signup failure', () async {
        authService.signupSuccess = false;
        expect(
          () => authService.signup('new@example.com', 'New User', 'password123'),
          throwsException,
        );
      });

      test('throws exception when service error occurs', () async {
        authService.exception = Exception('Server error');
        expect(
          () => authService.signup('new@example.com', 'New User', 'password123'),
          throwsException,
        );
      });

      test('signup creates user with correct name', () async {
        const name = 'John Doe';
        final user = await authService.signup('john@example.com', name, 'password');
        expect(user.name, equals(name));
      });
    });

    group('Logout', () {
      test('successfully logs out user', () async {
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

      test('throws exception when logout fails', () async {
        authService.exception = Exception('Logout failed');
        expect(
          () => authService.logout(),
          throwsException,
        );
      });
    });

    group('Token Refresh', () {
      test('successfully refreshes token', () async {
        final result = await authService.refreshToken();
        expect(result, equals(true));
      });

      test('throws exception on refresh failure', () async {
        authService.exception = Exception('Token refresh failed');
        expect(
          () => authService.refreshToken(),
          throwsException,
        );
      });

      test('can refresh token after login', () async {
        await authService.login('test@example.com', 'password123');
        final result = await authService.refreshToken();
        expect(result, equals(true));
      });
    });

    group('Get Current User', () {
      test('returns null when no user logged in', () {
        expect(authService.getCurrentUser(), isNull);
      });

      test('returns current user after login', () async {
        final loginUser = await authService.login('test@example.com', 'password123');
        final currentUser = authService.getCurrentUser();
        expect(currentUser, equals(loginUser));
      });

      test('returns null after logout', () async {
        await authService.login('test@example.com', 'password123');
        await authService.logout();
        expect(authService.getCurrentUser(), isNull);
      });
    });

    group('Reset Password', () {
      test('successfully initiates password reset', () async {
        expect(
          () => authService.resetPassword('test@example.com'),
          returnsNormally,
        );
      });

      test('throws exception on reset password failure', () async {
        authService.exception = Exception('Reset failed');
        expect(
          () => authService.resetPassword('test@example.com'),
          throwsException,
        );
      });
    });

    group('Verify Reset Token', () {
      test('successfully verifies reset token', () async {
        final user = await authService.verifyResetToken('valid-token');
        expect(user, isNotNull);
        expect(user.email, equals('test@example.com'));
      });

      test('throws exception on invalid token', () async {
        authService.exception = Exception('Invalid token');
        expect(
          () => authService.verifyResetToken('invalid-token'),
          throwsException,
        );
      });
    });

    group('Update Password', () {
      test('successfully updates password with valid token', () async {
        expect(
          () => authService.updatePassword('valid-token', 'newpassword123'),
          returnsNormally,
        );
      });

      test('throws exception on invalid token', () async {
        authService.exception = Exception('Invalid token');
        expect(
          () => authService.updatePassword('invalid-token', 'newpassword123'),
          throwsException,
        );
      });
    });
  });
}
