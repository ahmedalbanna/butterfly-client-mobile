import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import 'http_client.dart';
import 'auth_service.dart';

final orderServiceProvider = Provider((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return AdminOrderService(httpClient);
});

class AdminOrderService {
  final HttpClient _httpClient;
  final Logger _logger = Logger();

  AdminOrderService(this._httpClient);

  /// Fetch all orders for admin
  Future<AdminOrdersResponse> getOrders({
    int page = 1,
    int limit = AppConfig.defaultPageSize,
    String? status,
    String sortBy = 'date',
    String sortOrder = 'desc',
  }) async {
    try {
      _logger.i('Fetching admin orders - Page: $page');

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/admin/orders',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          'sortBy': sortBy,
          'sortOrder': sortOrder,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          return AdminOrdersResponse.fromJson(data);
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

  /// Get order detail
  Future<AdminOrder> getOrder(String id) async {
    try {
      _logger.i('Fetching order: $id');

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/admin/orders/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          return AdminOrder.fromJson(data['data']);
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

  /// Update order status
  Future<AdminOrder> updateOrderStatus({
    required String id,
    required String status,
  }) async {
    try {
      _logger.i('Updating order status: $id -> $status');

      final response = await _httpClient.put<Map<String, dynamic>>(
        '/admin/orders/$id',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          return AdminOrder.fromJson(data['data']);
        }
      }

      throw OrderException(
        response.data?['error'] ?? 'Failed to update order',
      );
    } catch (e) {
      _logger.e('Update order error: $e');
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

class AdminUser {
  final String id;
  final String email;
  final String? name;

  AdminUser({required this.id, required this.email, this.name});

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
    );
  }
}

class AdminOrderItem {
  final String id;
  final String productId;
  final int quantity;
  final double price;

  AdminOrderItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  double get subtotal => price * quantity;

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    return AdminOrderItem(
      id: json['id'],
      productId: json['productId'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }
}

class AdminOrder {
  final String id;
  final String status;
  final double total;
  final String? shippingAddress;
  final AdminUser user;
  final List<AdminOrderItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdminOrder({
    required this.id,
    required this.status,
    required this.total,
    this.shippingAddress,
    required this.user,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    return AdminOrder(
      id: json['id'],
      status: json['status'],
      total: (json['total'] as num).toDouble(),
      shippingAddress: json['shippingAddress'],
      user: AdminUser.fromJson(json['user']),
      items: (json['items'] as List)
          .map((item) => AdminOrderItem.fromJson(item))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}

class AdminOrdersResponse {
  final List<AdminOrder> data;
  final PaginationInfo pagination;

  AdminOrdersResponse({required this.data, required this.pagination});

  factory AdminOrdersResponse.fromJson(Map<String, dynamic> json) {
    return AdminOrdersResponse(
      data: (json['data'] as List)
          .map((order) => AdminOrder.fromJson(order))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      pages: json['pages'],
    );
  }
}

/// Providers
final adminOrdersProvider =
    FutureProvider.family<AdminOrdersResponse, AdminOrdersParams>(
  (ref, params) async {
    final service = ref.watch(orderServiceProvider);
    return service.getOrders(
      page: params.page,
      limit: params.limit,
      status: params.status,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  },
);

final adminOrderProvider = FutureProvider.family<AdminOrder, String>(
  (ref, orderId) async {
    final service = ref.watch(orderServiceProvider);
    return service.getOrder(orderId);
  },
);

class AdminOrdersParams {
  final int page;
  final int limit;
  final String? status;
  final String sortBy;
  final String sortOrder;

  AdminOrdersParams({
    this.page = 1,
    this.limit = AppConfig.defaultPageSize,
    this.status,
    this.sortBy = 'date',
    this.sortOrder = 'desc',
  });

  AdminOrdersParams copyWith({
    int? page,
    int? limit,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) {
    return AdminOrdersParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      status: status ?? this.status,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
