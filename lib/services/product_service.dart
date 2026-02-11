import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/product.dart';
import '../config/app_config.dart';
import 'http_client.dart';
import 'auth_service.dart';

final productServiceProvider = Provider((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return ProductService(httpClient);
});

class ProductService {
  final HttpClient _httpClient;
  final Logger _logger = Logger();

  ProductService(this._httpClient);

  /// Fetch products with pagination and filtering
  Future<ProductsResponse> getProducts({
    int page = 1,
    int limit = AppConfig.defaultPageSize,
    String? categoryId,
    String? search,
    String sortBy = 'newest',
    String sortOrder = 'asc',
    bool inStock = true,
  }) async {
    try {
      _logger.i('Fetching products - Page: $page, CategoryId: $categoryId');

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/products',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (categoryId != null) 'categoryId': categoryId,
          if (search != null) 'search': search,
          'sortBy': sortBy,
          'sortOrder': sortOrder,
          'inStock': inStock,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          return ProductsResponse.fromJson(data);
        }
      }

      throw ProductException(
        response.data?['error'] ?? 'Failed to fetch products',
      );
    } catch (e) {
      _logger.e('Get products error: $e');
      if (e is ProductException) {
        rethrow;
      }
      throw ProductException(e.toString());
    }
  }

  /// Fetch a single product by ID
  Future<Product> getProduct(String id) async {
    try {
      _logger.i('Fetching product: $id');

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/products/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          return Product.fromJson(data['data']);
        }
      }

      throw ProductException(
        response.data?['error'] ?? 'Product not found',
      );
    } catch (e) {
      _logger.e('Get product error: $e');
      if (e is ProductException) {
        rethrow;
      }
      throw ProductException(e.toString());
    }
  }

  /// Fetch all categories
  Future<List<Category>> getCategories() async {
    try {
      _logger.i('Fetching categories');

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/categories',
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          final categoriesData = data['data'] as List;
          return categoriesData
              .map((cat) => Category.fromJson(cat))
              .toList();
        }
      }

      throw ProductException(
        response.data?['error'] ?? 'Failed to fetch categories',
      );
    } catch (e) {
      _logger.e('Get categories error: $e');
      if (e is ProductException) {
        rethrow;
      }
      throw ProductException(e.toString());
    }
  }
}

class ProductException implements Exception {
  final String message;

  ProductException(this.message);

  @override
  String toString() => message;
}

/// Providers for products and categories
final productsProvider = FutureProvider.family<ProductsResponse, ProductsParams>(
  (ref, params) async {
    final service = ref.watch(productServiceProvider);
    return service.getProducts(
      page: params.page,
      limit: params.limit,
      categoryId: params.categoryId,
      search: params.search,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
      inStock: params.inStock,
    );
  },
);

final productDetailsProvider = FutureProvider.family<Product, String>(
  (ref, productId) async {
    final service = ref.watch(productServiceProvider);
    return service.getProduct(productId);
  },
);

final categoriesProvider = FutureProvider<List<Category>>(
  (ref) async {
    final service = ref.watch(productServiceProvider);
    return service.getCategories();
  },
);

class ProductsParams {
  final int page;
  final int limit;
  final String? categoryId;
  final String? search;
  final String sortBy;
  final String sortOrder;
  final bool inStock;

  ProductsParams({
    this.page = 1,
    this.limit = AppConfig.defaultPageSize,
    this.categoryId,
    this.search,
    this.sortBy = 'newest',
    this.sortOrder = 'asc',
    this.inStock = true,
  });

  ProductsParams copyWith({
    int? page,
    int? limit,
    String? categoryId,
    String? search,
    String? sortBy,
    String? sortOrder,
    bool? inStock,
  }) {
    return ProductsParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      categoryId: categoryId ?? this.categoryId,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      inStock: inStock ?? this.inStock,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductsParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          categoryId == other.categoryId &&
          search == other.search &&
          sortBy == other.sortBy &&
          sortOrder == other.sortOrder &&
          inStock == other.inStock;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      categoryId.hashCode ^
      search.hashCode ^
      sortBy.hashCode ^
      sortOrder.hashCode ^
      inStock.hashCode;
}
