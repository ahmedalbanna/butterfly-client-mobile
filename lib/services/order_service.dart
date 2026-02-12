import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/order.dart';
import '../config/app_config.dart';
import 'http_client.dart';
import 'auth_service.dart';

final orderServiceProvider = Provider((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return OrderService(httpClient);
});

class OrderService {
  final HttpClient _httpClient;
  final Logger _logger = Logger();

  OrderService(this._httpClient);

  /// Fetch user's orders with pagination
  Future<OrdersResponse> getOrders({
    int page = 1,
    int limit = AppConfig.defaultPageSize,
  }) async {
    try {
      _logger.i('Fetching orders - Page: $page');

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/orders',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          return OrdersResponse.fromJson(data);
        }
      }

      throw OrderException(
        response.data?['error'] ?? 'Failed to fetch orders',
      );
    } catch (e) {
      _logger.e('Get orders error: $e');
      if (e is OrderException) {
        rethrow;
      }
      throw OrderException(e.toString());
    }
  }

  /// Fetch a single order by ID
  Future<Order> getOrder(String id) async {
    try {
      _logger.i('Fetching order: $id');

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/orders/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          return Order.fromJson(data['data']);
        }
      }

      throw OrderException(
        response.data?['error'] ?? 'Order not found',
      );
    } catch (e) {
      _logger.e('Get order error: $e');
      if (e is OrderException) {
        rethrow;
      }
      throw OrderException(e.toString());
    }
  }

  /// Create a new order
  Future<Order> createOrder({
    required String customerAddress,
    String paymentMethod = 'credit_card',
  }) async {
    try {
      _logger.i('Creating order - Address: $customerAddress');

      final response = await _httpClient.post<Map<String, dynamic>>(
        '/orders',
        data: {
          'customerAddress': customerAddress,
          'paymentMethod': paymentMethod,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          return Order.fromJson(data['data']);
        }
      }

      throw OrderException(
        response.data?['error'] ?? 'Failed to create order',
      );
    } catch (e) {
      _logger.e('Create order error: $e');
      if (e is OrderException) {
        rethrow;
      }
      throw OrderException(e.toString());
    }
  }
}

class OrderException implements Exception {
  final String message;

  OrderException(this.message);

  @override
  String toString() => message;
}

/// Providers for orders
final ordersProvider = FutureProvider.family<OrdersResponse, OrdersParams>(
  (ref, params) async {
    final service = ref.watch(orderServiceProvider);
    return service.getOrders(
      page: params.page,
      limit: params.limit,
    );
  },
);

final orderDetailsProvider = FutureProvider.family<Order, String>(
  (ref, orderId) async {
    final service = ref.watch(orderServiceProvider);
    return service.getOrder(orderId);
  },
);

class OrdersParams {
  final int page;
  final int limit;

  OrdersParams({
    this.page = 1,
    this.limit = AppConfig.defaultPageSize,
  });

  OrdersParams copyWith({
    int? page,
    int? limit,
  }) {
    return OrdersParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrdersParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode => page.hashCode ^ limit.hashCode;
}

/// Order state notifier for checkout
final checkoutNotifierProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>(
  (ref) {
    final service = ref.watch(orderServiceProvider);
    return CheckoutNotifier(service);
  },
);

class CheckoutState {
  final Order? order;
  final bool isLoading;
  final String? error;

  CheckoutState({
    this.order,
    this.isLoading = false,
    this.error,
  });

  bool get isSuccess => order != null;

  CheckoutState copyWith({
    Order? order,
    bool? isLoading,
    String? error,
  }) {
    return CheckoutState(
      order: order ?? this.order,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  CheckoutState clearError() {
    return CheckoutState(order: order, isLoading: isLoading);
  }

  CheckoutState reset() {
    return CheckoutState();
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final OrderService _orderService;

  CheckoutNotifier(this._orderService) : super(CheckoutState());

  Future<void> checkout({
    required String customerAddress,
    String paymentMethod = 'credit_card',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final order = await _orderService.createOrder(
        customerAddress: customerAddress,
        paymentMethod: paymentMethod,
      );
      state = CheckoutState(order: order);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void reset() {
    state = CheckoutState();
  }

  void clearError() {
    state = state.clearError();
  }
}
