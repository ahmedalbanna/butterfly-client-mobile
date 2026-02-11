import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'http_client.dart';

final logger = Logger();

/// Category model
class Category {
  final String id;
  final String name;
  final String slug;
  final String description;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String? ?? '',
      displayOrder: json['displayOrder'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'displayOrder': displayOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Custom exception for category-related errors
class CategoryException implements Exception {
  final String message;

  CategoryException(this.message);

  @override
  String toString() => message;
}

/// Category service for managing product categories
class CategoryService {
  final HttpClient _httpClient;

  CategoryService(this._httpClient);

  /// Get all categories
  Future<List<Category>> getCategories() async {
    try {
      logger.d('[CategoryService] Fetching categories');
      final response = await _httpClient.get('/admin/categories');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => Category.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw CategoryException(response.data['error'] ?? 'Failed to fetch categories');
      }
    } catch (e) {
      logger.e('[CategoryService] Error fetching categories: $e');
      if (e is CategoryException) rethrow;
      throw CategoryException('Failed to fetch categories: ${e.toString()}');
    }
  }

  /// Create a new category
  Future<Category> createCategory({
    required String name,
    required String slug,
    String? description,
    int displayOrder = 0,
  }) async {
    try {
      logger.d('[CategoryService] Creating category: $name');
      final response = await _httpClient.post(
        '/admin/categories',
        data: {
          'name': name,
          'slug': slug,
          'description': description ?? '',
          'displayOrder': displayOrder,
        },
      );

      if (response.data['success'] == true) {
        return Category.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw CategoryException(response.data['error'] ?? 'Failed to create category');
      }
    } catch (e) {
      logger.e('[CategoryService] Error creating category: $e');
      if (e is CategoryException) rethrow;
      throw CategoryException('Failed to create category: ${e.toString()}');
    }
  }

  /// Update an existing category
  Future<Category> updateCategory({
    required String id,
    String? name,
    String? slug,
    String? description,
    int? displayOrder,
  }) async {
    try {
      logger.d('[CategoryService] Updating category: $id');
      final Map<String, dynamic> data = {};
      
      if (name != null) data['name'] = name;
      if (slug != null) data['slug'] = slug;
      if (description != null) data['description'] = description;
      if (displayOrder != null) data['displayOrder'] = displayOrder;

      final response = await _httpClient.put(
        '/admin/categories/$id',
        data: data,
      );

      if (response.data['success'] == true) {
        return Category.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw CategoryException(response.data['error'] ?? 'Failed to update category');
      }
    } catch (e) {
      logger.e('[CategoryService] Error updating category: $e');
      if (e is CategoryException) rethrow;
      throw CategoryException('Failed to update category: ${e.toString()}');
    }
  }

  /// Delete a category
  Future<void> deleteCategory(String id) async {
    try {
      logger.d('[CategoryService] Deleting category: $id');
      final response = await _httpClient.delete('/admin/categories/$id');

      if (response.data['success'] != true) {
        throw CategoryException(response.data['error'] ?? 'Failed to delete category');
      }
    } catch (e) {
      logger.e('[CategoryService] Error deleting category: $e');
      if (e is CategoryException) rethrow;
      throw CategoryException('Failed to delete category: ${e.toString()}');
    }
  }
}

/// Provider for CategoryService
final categoryServiceProvider = Provider<CategoryService>((ref) {
  final httpClient = HttpClient();
  return CategoryService(httpClient);
});

/// Provider for fetching categories
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final categoryService = ref.watch(categoryServiceProvider);
  return categoryService.getCategories();
});
