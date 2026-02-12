import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/user.dart';
import '../config/app_config.dart';
import 'http_client.dart';

final httpClientProvider = Provider((ref) => HttpClient());

final authServiceProvider = Provider((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return AuthService(httpClient);
});

class AuthService {
  final HttpClient _httpClient;
  final Logger _logger = Logger();

  AuthService(this._httpClient);

  /// Login with email and password
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Logging in user: $email');

      final response = await _httpClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          final user = User.fromJson(data['user']);
          final accessToken = data['accessToken'] as String?;
          final refreshToken = data['refreshToken'] as String?;
          
          _logger.i('Login response received');
          _logger.d('Access token: ${accessToken != null ? 'Present (${accessToken.length} chars)' : 'NULL'}');
          _logger.d('Refresh token: ${refreshToken != null ? 'Present (${refreshToken.length} chars)' : 'NULL'}');
          
          // Save tokens to secure storage
          if (accessToken != null && refreshToken != null) {
            _logger.i('Saving tokens to secure storage...');
            await _httpClient.saveTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
            );
            _logger.i('✓ Tokens saved successfully');
          } else {
            _logger.e('✗ Cannot save tokens - accessToken or refreshToken is null');
          }
          
          _logger.i('User logged in successfully: ${user.email}');
          return user;
        }
      }

      throw AuthException(
        response.data?['error'] ?? 'Login failed',
      );
    } catch (e) {
      _logger.e('Login error: $e');
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(e.toString());
    }
  }

  /// Register a new user
  Future<User> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      _logger.i('Registering user: $email');

      final response = await _httpClient.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name ?? email.split('@')[0],
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          final user = User.fromJson(data['user']);
          final accessToken = data['accessToken'] as String?;
          final refreshToken = data['refreshToken'] as String?;
          
          _logger.i('Register response received');
          _logger.d('Access token: ${accessToken != null ? 'Present (${accessToken.length} chars)' : 'NULL'}');
          _logger.d('Refresh token: ${refreshToken != null ? 'Present (${refreshToken.length} chars)' : 'NULL'}');
          
          // Save tokens to secure storage
          if (accessToken != null && refreshToken != null) {
            _logger.i('Saving tokens to secure storage...');
            await _httpClient.saveTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
            );
            _logger.i('✓ Tokens saved successfully');
          } else {
            _logger.e('✗ Cannot save tokens - accessToken or refreshToken is null');
          }
          
          _logger.i('User registered successfully: ${user.email}');
          return user;
        }
      }

      throw AuthException(
        response.data?['error'] ?? 'Registration failed',
      );
    } catch (e) {
      _logger.e('Registration error: $e');
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(e.toString());
    }
  }

  /// Get current user
  Future<User> getCurrentUser() async {
    try {
      _logger.i('Fetching current user');

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/auth/me',
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        final user = User.fromJson(data['user']);
        _logger.i('Current user fetched: ${user.email}');
        return user;
      }

      throw AuthException('Failed to fetch user');
    } catch (e) {
      _logger.e('Get current user error: $e');
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(e.toString());
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      _logger.i('Logging out user');

      await _httpClient.post('/auth/logout');
      await _httpClient.clearTokens();

      _logger.i('User logged out successfully');
    } catch (e) {
      _logger.e('Logout error: $e');
      // Clear tokens even if logout endpoint fails
      await _httpClient.clearTokens();
    }
  }

  /// Refresh token
  Future<void> refreshToken() async {
    try {
      _logger.i('Refreshing token');

      final response = await _httpClient.post<Map<String, dynamic>>(
        '/auth/refresh',
      );

      if (response.statusCode == 200) {
        _logger.i('Token refreshed successfully');
      } else {
        throw AuthException('Failed to refresh token');
      }
    } catch (e) {
      _logger.e('Token refresh error: $e');
      throw AuthException(e.toString());
    }
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

/// Auth state provider
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.isAdmin ?? false;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  AuthState clearError() {
    return AuthState(user: user, isLoading: isLoading);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState(isLoading: true)) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final user = await _authService.getCurrentUser();
      state = AuthState(user: user);
    } catch (e) {
      // User not logged in
      state = AuthState(user: null);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );
      state = AuthState(user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.register(
        email: email,
        password: password,
        name: name,
      );
      state = AuthState(user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.logout();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void clearError() {
    state = state.clearError();
  }
}
