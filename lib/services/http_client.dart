import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';

class HttpClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger = Logger();
  bool _isRefreshing = false;
  final List<Function> _pendingRequests = [];

  HttpClient({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectionTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth token to headers
    final token = await getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    _logger.d('→ ${options.method} ${options.path}');
    return handler.next(options);
  }

  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    _logger.d('← ${response.statusCode} ${response.requestOptions.path}');
    return handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    _logger.e('✗ Error: ${error.message}');

    // Handle 401 - try to refresh token
    if (error.response?.statusCode == 401) {
      final refreshToken = await getRefreshToken();
      
      // No refresh token available, proceed with error
      if (refreshToken == null) {
        _logger.w('No refresh token available, cannot refresh');
        return handler.next(error);
      }

      // If already refreshing, queue this request
      if (_isRefreshing) {
        _logger.d('Token refresh in progress, queuing request');
        return _queueRequest(() async {
          return _retryRequest(error.requestOptions, handler);
        });
      }

      // Start token refresh process
      _isRefreshing = true;
      _logger.i('Attempting to refresh access token');

      try {
        // Call refresh endpoint
        final response = await _dio.post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data!;
          
          // Extract new tokens
          final newAccessToken = data['accessToken'] as String?;
          final newRefreshToken = data['refreshToken'] as String?;

          if (newAccessToken != null && newRefreshToken != null) {
            // Save new tokens
            await saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );
            _logger.i('Token refresh successful');

            // Retry original request with new token
            final retryResponse = await _retryRequest(
              error.requestOptions,
              handler,
            );

            // Process all pending requests
            _processPendingRequests();
            
            return retryResponse;
          }
        }

        // Refresh failed - clear tokens and logout
        _logger.e('Token refresh failed - invalid response');
        await _handleRefreshFailure();
        return handler.next(error);
      } catch (e) {
        _logger.e('Token refresh error: $e');
        await _handleRefreshFailure();
        return handler.next(error);
      } finally {
        _isRefreshing = false;
      }
    }

    return handler.next(error);
  }

  /// Queue a request while token refresh is in progress
  Future<void> _queueRequest(Function request) async {
    _pendingRequests.add(request);
  }

  /// Process all pending requests after token refresh
  void _processPendingRequests() {
    for (final request in _pendingRequests) {
      request();
    }
    _pendingRequests.clear();
  }

  /// Retry a failed request with new token
  Future<void> _retryRequest(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final token = await getAccessToken();
      final opts = Options(
        method: requestOptions.method,
        headers: {
          ...requestOptions.headers,
          'Authorization': 'Bearer $token',
        },
      );

      final response = await _dio.request(
        requestOptions.path,
        options: opts,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
      );

      return handler.resolve(response);
    } catch (e) {
      _logger.e('Retry request failed: $e');
      rethrow;
    }
  }

  /// Handle token refresh failure - clear tokens
  Future<void> _handleRefreshFailure() async {
    _logger.w('Clearing tokens due to refresh failure');
    await clearTokens();
    _pendingRequests.clear();
    // Note: Auto-logout will be handled by auth state provider
    // when it detects missing tokens on next API call
  }

  /// Get request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Post request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Put request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Delete request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Get access token from secure storage
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: AppConfig.tokenStorageKey);
  }

  /// Save tokens to secure storage
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secureStorage.write(key: AppConfig.tokenStorageKey, value: accessToken),
      _secureStorage.write(
        key: AppConfig.refreshTokenStorageKey,
        value: refreshToken,
      ),
    ]);
  }

  /// Clear tokens from secure storage
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: AppConfig.tokenStorageKey),
      _secureStorage.delete(key: AppConfig.refreshTokenStorageKey),
    ]);
  }

  /// Get refresh token from secure storage
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: AppConfig.refreshTokenStorageKey);
  }
}
