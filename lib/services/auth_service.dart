import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
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
      _logger.i('Admin logging in: $email');

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
          
          // Verify admin access
          if (!user.isAdmin) {
            throw AuthException('This account does not have admin access');
          }
          
          _logger.i('Admin logged in successfully: ${user.email}');
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

  /// Get current user
  Future<User> getCurrentUser() async {
    try {
      _logger.i('Fetching current admin user');

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/auth/me',
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        final user = User.fromJson(data['user']);
        
        // Verify admin access
        if (!user.isAdmin) {
          throw AuthException('This account does not have admin access');
        }
        
        _logger.i('Current admin user fetched: ${user.email}');
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
      _logger.i('Logging out admin');

      await _httpClient.post('/auth/logout');
      await _httpClient.clearTokens();

      _logger.i('Admin logged out successfully');
    } catch (e) {
      _logger.e('Logout error: $e');
      // Clear tokens even if logout endpoint fails
      await _httpClient.clearTokens();
    }
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

class User {
  final String id;
  final String email;
  final String? name;
  final bool isAdmin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    this.name,
    required this.isAdmin,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      isAdmin: json['isAdmin'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
}

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.isAdmin ?? false;

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
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
