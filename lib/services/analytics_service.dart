import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'http_client.dart';
import 'auth_service.dart';

final logger = Logger();

/// Order statistics by status
class OrderStatistics {
  final int total;
  final int pending;
  final int processing;
  final int shipped;
  final int delivered;
  final int cancelled;

  OrderStatistics({
    required this.total,
    required this.pending,
    required this.processing,
    required this.shipped,
    required this.delivered,
    required this.cancelled,
  });

  factory OrderStatistics.fromJson(Map<String, dynamic> json) {
    final byStatus = json['byStatus'] as Map<String, dynamic>;
    return OrderStatistics(
      total: json['total'] as int,
      pending: byStatus['pending'] as int,
      processing: byStatus['processing'] as int,
      shipped: byStatus['shipped'] as int,
      delivered: byStatus['delivered'] as int,
      cancelled: byStatus['cancelled'] as int,
    );
  }
}

/// Revenue statistics
class RevenueStatistics {
  final double total;
  final double today;
  final double thisWeek;
  final double thisMonth;

  RevenueStatistics({
    required this.total,
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
  });

  factory RevenueStatistics.fromJson(Map<String, dynamic> json) {
    return RevenueStatistics(
      total: (json['total'] as num).toDouble(),
      today: (json['today'] as num).toDouble(),
      thisWeek: (json['thisWeek'] as num).toDouble(),
      thisMonth: (json['thisMonth'] as num).toDouble(),
    );
  }
}

/// Recent order summary
class RecentOrder {
  final String id;
  final String status;
  final double total;
  final DateTime createdAt;
  final OrderCustomer customer;
  final int itemCount;

  RecentOrder({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.customer,
    required this.itemCount,
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    return RecentOrder(
      id: json['id'] as String,
      status: json['status'] as String,
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      customer: OrderCustomer.fromJson(json['customer'] as Map<String, dynamic>),
      itemCount: json['itemCount'] as int,
    );
  }

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
}

/// Customer info for recent orders
class OrderCustomer {
  final String id;
  final String? name;
  final String email;

  OrderCustomer({
    required this.id,
    this.name,
    required this.email,
  });

  factory OrderCustomer.fromJson(Map<String, dynamic> json) {
    return OrderCustomer(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String,
    );
  }
}

/// Low stock product
class LowStockProduct {
  final String id;
  final String name;
  final int stock;
  final double price;
  final String categoryName;
  final int suggestedRestock;

  LowStockProduct({
    required this.id,
    required this.name,
    required this.stock,
    required this.price,
    required this.categoryName,
    required this.suggestedRestock,
  });

  factory LowStockProduct.fromJson(Map<String, dynamic> json) {
    return LowStockProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      stock: json['stock'] as int,
      price: (json['price'] as num).toDouble(),
      categoryName: json['categoryName'] as String,
      suggestedRestock: json['suggestedRestock'] as int,
    );
  }
}

/// Product statistics
class ProductStatistics {
  final int total;
  final int outOfStock;
  final int lowStock;

  ProductStatistics({
    required this.total,
    required this.outOfStock,
    required this.lowStock,
  });

  factory ProductStatistics.fromJson(Map<String, dynamic> json) {
    return ProductStatistics(
      total: json['total'] as int,
      outOfStock: json['outOfStock'] as int,
      lowStock: json['lowStock'] as int,
    );
  }
}

/// Dashboard analytics aggregate
class DashboardAnalytics {
  final OrderStatistics orders;
  final RevenueStatistics revenue;
  final List<RecentOrder> recentOrders;
  final List<LowStockProduct> lowStockProducts;
  final ProductStatistics products;

  DashboardAnalytics({
    required this.orders,
    required this.revenue,
    required this.recentOrders,
    required this.lowStockProducts,
    required this.products,
  });

  factory DashboardAnalytics.fromJson(Map<String, dynamic> json) {
    return DashboardAnalytics(
      orders: OrderStatistics.fromJson(json['orders'] as Map<String, dynamic>),
      revenue: RevenueStatistics.fromJson(json['revenue'] as Map<String, dynamic>),
      recentOrders: (json['recentOrders'] as List<dynamic>)
          .map((item) => RecentOrder.fromJson(item as Map<String, dynamic>))
          .toList(),
      lowStockProducts: (json['lowStockProducts'] as List<dynamic>)
          .map((item) => LowStockProduct.fromJson(item as Map<String, dynamic>))
          .toList(),
      products: ProductStatistics.fromJson(json['products'] as Map<String, dynamic>),
    );
  }
}

/// Custom exception for analytics-related errors
class AnalyticsException implements Exception {
  final String message;

  AnalyticsException(this.message);

  @override
  String toString() => message;
}

/// Analytics service for fetching dashboard data
class AnalyticsService {
  final HttpClient _httpClient;

  AnalyticsService(this._httpClient);

  /// Get dashboard analytics
  Future<DashboardAnalytics> getDashboardAnalytics() async {
    try {
      logger.d('[AnalyticsService] Fetching dashboard analytics');
      final response = await _httpClient.get('/admin/analytics');

      if (response.data['success'] == true) {
        return DashboardAnalytics.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw AnalyticsException(
          response.data['error'] ?? 'Failed to fetch analytics',
        );
      }
    } catch (e) {
      logger.e('[AnalyticsService] Error fetching analytics: $e');
      if (e is AnalyticsException) rethrow;
      throw AnalyticsException('Failed to fetch analytics: ${e.toString()}');
    }
  }
}

/// Provider for AnalyticsService
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return AnalyticsService(httpClient);
});

/// Provider for fetching dashboard analytics
final analyticsProvider = FutureProvider<DashboardAnalytics>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.getDashboardAnalytics();
});
