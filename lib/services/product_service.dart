import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import 'http_client.dart';
import 'auth_service.dart';

final productServiceProvider = Provider((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return AdminProductService(httpClient);
});

class AdminProductService {
  final HttpClient _httpClient;
  final Logger _logger = Logger();

  AdminProductService(this._httpClient);

  /// Fetch products for admin with pagination
  Future<AdminProductsResponse> getProducts({
    int page = 1,
    int limit = AppConfig.defaultPageSize,
    String? search,
    String? categoryId,
  }) async {
    try {
      _logger.i('Fetching admin products - Page: $page');

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/admin/products',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null) 'search': search,
          if (categoryId != null) 'categoryId': categoryId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          return AdminProductsResponse.fromJson(data);
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

  /// Create a new product
  Future<AdminProduct> createProduct({
    required String name,
    required String description,
    required String categoryId,
    required double price,
    required int stock,
    required String image,
    List<String> images = const [],
    String? materials,
    String? care,
    bool featured = false,
  }) async {
    try {
      _logger.i('Creating product: $name');

      final response = await _httpClient.post<Map<String, dynamic>>(
        '/admin/products',
        data: {
          'name': name,
          'description': description,
          'categoryId': categoryId,
          'price': price,
          'stock': stock,
          'image': image,
          'images': images,
          'materials': materials ?? '',
          'care': care ?? '',
          'featured': featured,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          return AdminProduct.fromJson(data['data']);
        }
      }

      throw ProductException(
        response.data?['error'] ?? 'Failed to create product',
      );
    } catch (e) {
      _logger.e('Create product error: $e');
      if (e is ProductException) {
        rethrow;
      }
      throw ProductException(e.toString());
    }
  }

  /// Update a product
  Future<AdminProduct> updateProduct({
    required String id,
    String? name,
    String? description,
    String? categoryId,
    double? price,
    int? stock,
    String? image,
    List<String>? images,
    String? materials,
    String? care,
    bool? featured,
  }) async {
    try {
      _logger.i('Updating product: $id');

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (categoryId != null) data['categoryId'] = categoryId;
      if (price != null) data['price'] = price;
      if (stock != null) data['stock'] = stock;
      if (image != null) data['image'] = image;
      if (images != null) data['images'] = images;
      if (materials != null) data['materials'] = materials;
      if (care != null) data['care'] = care;
      if (featured != null) data['featured'] = featured;

      final response = await _httpClient.put<Map<String, dynamic>>(
        '/admin/products/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data!;
        if (responseData['success'] == true) {
          return AdminProduct.fromJson(responseData['data']);
        }
      }

      throw ProductException(
        response.data?['error'] ?? 'Failed to update product',
      );
    } catch (e) {
      _logger.e('Update product error: $e');
      if (e is ProductException) {
        rethrow;
      }
      throw ProductException(e.toString());
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String id) async {
    try {
      _logger.i('Deleting product: $id');

      final response = await _httpClient.delete<Map<String, dynamic>>(
        '/admin/products/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          _logger.i('Product deleted successfully');
          return;
        }
      }

      throw ProductException(
        response.data?['error'] ?? 'Failed to delete product',
      );
    } catch (e) {
      _logger.e('Delete product error: $e');
      if (e is ProductException) {
        rethrow;
      }
      throw ProductException(e.toString());
    }
  }

  /// Fetch a single product
  Future<AdminProduct> getProduct(String id) async {
    try {
      _logger.i('Fetching product: $id');

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/admin/products/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          return AdminProduct.fromJson(data['data']);
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
}

class ProductException implements Exception {
  final String message;

  ProductException(this.message);

  @override
  String toString() => message;
}

class AdminCategory {
  final String id;
  final String name;

  AdminCategory({required this.id, required this.name});

  factory AdminCategory.fromJson(Map<String, dynamic> json) {
    return AdminCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}

class AdminProduct {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String description;
  final String image;
  final bool featured;
  final String categoryId;
  final AdminCategory category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdminProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
    required this.image,
    required this.featured,
    required this.categoryId,
    required this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminProduct.fromJson(Map<String, dynamic> json) {
    return AdminProduct(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      stock: json['stock'],
      description: json['description'],
      image: json['image'],
      featured: json['featured'] ?? false,
      categoryId: json['categoryId'],
      category: AdminCategory.fromJson(json['category']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}

class AdminProductsResponse {
  final List<AdminProduct> data;
  final PaginationInfo pagination;

  AdminProductsResponse({required this.data, required this.pagination});

  factory AdminProductsResponse.fromJson(Map<String, dynamic> json) {
    return AdminProductsResponse(
      data: (json['data'] as List)
          .map((p) => AdminProduct.fromJson(p))
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
final adminProductsProvider =
    FutureProvider.family<AdminProductsResponse, AdminProductsParams>(
  (ref, params) async {
    final service = ref.watch(productServiceProvider);
    return service.getProducts(
      page: params.page,
      limit: params.limit,
      search: params.search,
      categoryId: params.categoryId,
    );
  },
);

final adminProductProvider = FutureProvider.family<AdminProduct, String>(
  (ref, productId) async {
    final service = ref.watch(productServiceProvider);
    return service.getProduct(productId);
  },
);

class AdminProductsParams {
  final int page;
  final int limit;
  final String? search;
  final String? categoryId;

  AdminProductsParams({
    this.page = 1,
    this.limit = AppConfig.defaultPageSize,
    this.search,
    this.categoryId,
  });

  AdminProductsParams copyWith({
    int? page,
    int? limit,
    String? search,
    String? categoryId,
  }) {
    return AdminProductsParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
