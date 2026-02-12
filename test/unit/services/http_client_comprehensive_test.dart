import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luxefinds_client/services/http_client.dart';

import '../../helpers/test_fixtures.dart';
import '../../mocks/mock_services.dart';

void main() {
  group('HttpClient Comprehensive Tests', () {
    late FakeHttpClient httpClient;

    setUp(() {
      httpClient = FakeHttpClient();
    });

    group('GET Requests', () {
      test('successfully performs GET request', () async {
        httpClient = FakeHttpClient(
          responseBuilder: (url) => userLoginResponse,
        );
        final response = await httpClient.get('/api/user');
        expect(response, isNotNull);
        expect(response['success'], equals(true));
      });

      test('includes headers in GET request', () async {
        httpClient = FakeHttpClient(
          responseBuilder: (url) => {},
        );
        final response = await httpClient.get(
          '/api/products',
          headers: {'Authorization': 'Bearer token'},
        );
        expect(response, isNotNull);
      });

      test('throws exception on GET error', () async {
        httpClient = FakeHttpClient(
          exception: Exception('Network error'),
        );
        expect(
          () => httpClient.get('/api/products'),
          throwsException,
        );
      });

      test('handles empty GET response', () async {
        httpClient = FakeHttpClient(
          responseBuilder: (url) => {},
        );
        final response = await httpClient.get('/api/empty');
        expect(response, isNotNull);
      });
    });

    group('POST Requests', () {
      test('successfully performs POST request', () async {
        httpClient = FakeHttpClient(
          responseBuilder: (url) => userLoginResponse,
        );
        final response = await httpClient.post(
          '/api/auth/login',
          data: {'email': 'test@example.com', 'password': 'password123'},
        );
        expect(response['success'], equals(true));
      });

      test('includes data in POST request', () async {
        httpClient = FakeHttpClient(
          responseBuilder: (url) => {},
        );
        final data = {'name': 'John', 'email': 'john@example.com'};
        final response = await httpClient.post('/api/users', data: data);
        expect(response, isNotNull);
      });

      test('includes headers in POST request', () async {
        httpClient = FakeHttpClient(
          responseBuilder: (url) => {},
        );
        final response = await httpClient.post(
          '/api/orders',
          data: {'items': []},
          headers: {'Authorization': 'Bearer token'},
        );
        expect(response, isNotNull);
      });

      test('throws exception on POST error', () async {
        httpClient = FakeHttpClient(
          exception: DioException(
            requestOptions: RequestOptions(path: '/api/auth/login'),
            message: 'Invalid credentials',
          ),
        );
        expect(
          () => httpClient.post('/api/auth/login', data: {}),
          throwsException,
        );
      });
    });

    group('PUT Requests', () {
      test('successfully performs PUT request', () async {
        httpClient = FakeHttpClient(
          responseBuilder: (url) => {},
        );
        final response = await httpClient.put(
          '/api/cart/item/1',
          data: {'quantity': 5},
        );
        expect(response, isNotNull);
      });

      test('includes data in PUT request', () async {
        httpClient = FakeHttpClient(
          responseBuilder: (url) => {},
        );
        final response = await httpClient.put(
          '/api/users/123',
          data: {'name': 'Updated Name'},
        );
        expect(response, isNotNull);
      });

      test('throws exception on PUT error', () async {
        httpClient = FakeHttpClient(
          exception: Exception('Update failed'),
        );
        expect(
          () => httpClient.put('/api/users/123', data: {}),
          throwsException,
        );
      });
    });

    group('DELETE Requests', () {
      test('successfully performs DELETE request', () async {
        httpClient = FakeHttpClient(
          responseBuilder: (url) => {},
        );
        final response = await httpClient.delete('/api/cart/items/1');
        expect(response, isNotNull);
      });

      test('includes headers in DELETE request', () async {
        httpClient = FakeHttpClient(
          responseBuilder: (url) => {},
        );
        final response = await httpClient.delete(
          '/api/orders/123',
          headers: {'Authorization': 'Bearer token'},
        );
        expect(response, isNotNull);
      });

      test('throws exception on DELETE error', () async {
        httpClient = FakeHttpClient(
          exception: Exception('Delete failed'),
        );
        expect(
          () => httpClient.delete('/api/cart/items/1'),
          throwsException,
        );
      });
    });

    group('Token Management', () {
      test('sets authorization header', () async {
        expect(
          () => httpClient.setAuthorizationHeader('test-token'),
          returnsNormally,
        );
      });

      test('clears authorization header', () async {
        httpClient.setAuthorizationHeader('test-token');
        expect(
          () => httpClient.clearAuthorizationHeader(),
          returnsNormally,
        );
      });

      test('successfully refreshes token', () async {
        httpClient = FakeHttpClient(
          responseBuilder: (url) => tokenRefreshResponse,
        );
        expect(
          () => httpClient.refreshToken(),
          returnsNormally,
        );
      });

      test('throws exception on refresh token failure', () async {
        httpClient = FakeHttpClient(
          exception: Exception('Token refresh failed'),
        );
        expect(
          () => httpClient.refreshToken(),
          throwsException,
        );
      });
    });

    group('Request Counting', () {
      test('tracks number of requests', () async {
        httpClient = FakeHttpClient(
          responseBuilder: (url) => {},
        );
        expect(httpClient.requestCount, equals(0));
        await httpClient.get('/api/products');
        expect(httpClient.requestCount, equals(1));
        await httpClient.post('/api/orders', data: {});
        expect(httpClient.requestCount, equals(2));
      });

      test('increments count on each request type', () async {
        httpClient = FakeHttpClient(
          responseBuilder: (url) => {},
        );
        await httpClient.get('/test');
        await httpClient.post('/test', data: {});
        await httpClient.put('/test', data: {});
        await httpClient.delete('/test');
        expect(httpClient.requestCount, equals(4));
      });
    });

    group('Response Parsing', () {
      test('returns response as map', () async {
        httpClient = FakeHttpClient(
          responseBuilder: (url) => {'id': '123', 'name': 'Test'},
        );
        final response = await httpClient.get('/api/test');
        expect(response, isA<Map<String, dynamic>>());
        expect(response['id'], equals('123'));
      });

      test('handles complex nested responses', () async {
        httpClient = FakeHttpClient(
          responseBuilder: (url) => {
            'success': true,
            'data': {
              'user': {'id': '123', 'email': 'test@example.com'},
              'token': 'abc123',
            },
          },
        );
        final response = await httpClient.get('/api/auth/me');
        expect(response['success'], equals(true));
        expect(response['data']['user']['id'], equals('123'));
      });
    });

    group('Error Handling', () {
      test('handles network errors', () async {
        httpClient = FakeHttpClient(
          exception: Exception('Network timeout'),
        );
        expect(
          () => httpClient.get('/api/products'),
          throwsException,
        );
      });

      test('handles 401 unauthorized', () async {
        httpClient = FakeHttpClient(
          exception: DioException(
            requestOptions: RequestOptions(path: '/api/protected'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/protected'),
              statusCode: 401,
            ),
          ),
        );
        expect(
          () => httpClient.get('/api/protected'),
          throwsException,
        );
      });

      test('handles 500 server error', () async {
        httpClient = FakeHttpClient(
          exception: DioException(
            requestOptions: RequestOptions(path: '/api/error'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/error'),
              statusCode: 500,
            ),
          ),
        );
        expect(
          () => httpClient.get('/api/error'),
          throwsException,
        );
      });

      test('handles connection error', () async {
        httpClient = FakeHttpClient(
          exception: Exception('Failed to connect'),
        );
        expect(
          () => httpClient.get('/api/products'),
          throwsException,
        );
      });
    });
  });
}
