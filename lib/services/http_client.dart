import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';

class HttpClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger = Logger();

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

    if (error.response?.statusCode == 401) {
      // Attempt to refresh token
      try {
        final refreshToken = await getRefreshToken();
        
        if (refreshToken != null) {
          _logger.i('Attempting to refresh access token');
          
          final refreshResponse = await _dio.post<Map<String, dynamic>>(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
            options: Options(
              headers: {'Authorization': 'Bearer $refreshToken'},
            ),
          );
          
          if (refreshResponse.statusCode == 200) {
            final data = refreshResponse.data!;
            if (data['success'] == true) {
              final newAccessToken = data['accessToken'];
              final newRefreshToken = data['refreshToken'];
              
              if (newAccessToken != null && newRefreshToken != null) {
                // Save new tokens
                await saveTokens(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken,
                );
                
                _logger.i('Token refreshed successfully');
                
                // Retry the original request with new token
                final retryOptions = error.requestOptions;
                retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                
                try {
                  final retryResponse = await _dio.request<dynamic>(
                    retryOptions.path,
                    options: Options(
                      method: retryOptions.method,
                      headers: retryOptions.headers,
                    ),
                    data: retryOptions.data,
                    queryParameters: retryOptions.queryParameters,
                  );
                  return handler.resolve(retryResponse);
                } catch (retryError) {
                  _logger.e('Failed to retry request after token refresh: $retryError');
                  return handler.next(error);
                }
              }
            }
          }
        }
        
        // If we get here, refresh failed - clear tokens and let 401 propagate
        _logger.e('Token refresh failed, clearing stored tokens');
        await clearTokens();
      } catch (e) {
        _logger.e('Error during token refresh: $e');
        // Clear tokens on any error
        await clearTokens();
      }
    }

    return handler.next(error);
  }

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

  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: AppConfig.tokenStorageKey);
  }

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

  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: AppConfig.tokenStorageKey),
      _secureStorage.delete(key: AppConfig.refreshTokenStorageKey),
    ]);
  }

  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: AppConfig.refreshTokenStorageKey);
  }
}
