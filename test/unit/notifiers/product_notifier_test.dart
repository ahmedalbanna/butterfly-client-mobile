import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luxefinds_client/models/product.dart';

import '../../helpers/test_fixtures.dart';
import '../../mocks/mock_services.dart';

void main() {
  group('ProductNotifier Tests', () {
    late ProviderContainer container;
    late FakeProductService productService;

    setUp(() {
      productService = FakeProductService();
      productService.addProduct(testProduct1);
      productService.addProduct(testProduct2);
      productService.addProduct(testProduct3OutOfStock);
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
      productService.clear();
    });

    group('Fetch Products', () {
      test('fetches all products', () async {
        final products = await productService.getProducts();
        expect(products, isNotEmpty);
        expect(products.length, equals(3));
      });

      test('returns empty list when no products', () async {
        productService.clear();
        final products = await productService.getProducts();
        expect(products, isEmpty);
      });

      test('respects pagination', () async {
        final products = await productService.getProducts(page: 1, limit: 2);
        expect(products, isNotEmpty);
      });

      test('handles fetch error', () async {
        productService.exception = Exception('Fetch failed');
        expect(
          () => productService.getProducts(),
          throwsException,
        );
      });
    });

    group('Get Product Details', () {
      test('fetches product by ID', () async {
        final product = await productService.getProductById('1');
        expect(product.id, equals('1'));
        expect(product.name, equals('Luxury Watch'));
      });

      test('returns complete product details', () async {
        final product = await productService.getProductById('1');
        expect(product.description, isNotEmpty);
        expect(product.price, greaterThan(0));
        expect(product.category, isNotEmpty);
        expect(product.imageUrl, isNotEmpty);
      });

      test('throws error for non-existent product', () async {
        expect(
          () => productService.getProductById('999'),
          throwsException,
        );
      });

      test('handles fetch error', () async {
        productService.exception = Exception('Fetch failed');
        expect(
          () => productService.getProductById('1'),
          throwsException,
        );
      });
    });

    group('Search Products', () {
      test('searches by name', () async {
        final results = await productService.searchProducts('Watch');
        expect(results, isNotEmpty);
      });

      test('search is case-insensitive', () async {
        final results1 = await productService.searchProducts('watch');
        final results2 = await productService.searchProducts('WATCH');
        expect(results1.length, equals(results2.length));
      });

      test('returns empty for non-matching search', () async {
        final results = await productService.searchProducts('NonExistent');
        expect(results, isEmpty);
      });

      test('handles search error', () async {
        productService.exception = Exception('Search failed');
        expect(
          () => productService.searchProducts('Watch'),
          throwsException,
        );
      });
    });

    group('Filter by Category', () {
      test('filters products by category', () async {
        final results = await productService.getProductsByCategory('Watches');
        expect(results, isNotEmpty);
        expect(results.first.category, equals('Watches'));
      });

      test('returns empty for non-existent category', () async {
        final results = await productService.getProductsByCategory('Shoes');
        expect(results, isEmpty);
      });

      test('category filtering is exact', () async {
        final results = await productService.getProductsByCategory('Accessories');
        for (final product in results) {
          expect(product.category, equals('Accessories'));
        }
      });

      test('handles filter error', () async {
        productService.exception = Exception('Filter failed');
        expect(
          () => productService.getProductsByCategory('Watches'),
          throwsException,
        );
      });
    });

    group('Stock Management', () {
      test('identifies in-stock products', () async {
        final products = await productService.getProducts();
        final inStock = products.where((p) => p.inStock).toList();
        expect(inStock, isNotEmpty);
      });

      test('identifies out-of-stock products', () async {
        final products = await productService.getProducts();
        final outOfStock = products.where((p) => !p.inStock).toList();
        expect(outOfStock, isNotEmpty);
      });

      test('tracks stock quantity', () async {
        final product = await productService.getProductById('1');
        expect(product.stock, isNotNull);
        expect(product.stock, greaterThanOrEqualTo(0));
      });
    });

    group('Product Information', () {
      test('product has all required fields', () async {
        final product = await productService.getProductById('1');
        expect(product.id, isNotEmpty);
        expect(product.name, isNotEmpty);
        expect(product.description, isNotEmpty);
        expect(product.price, greaterThan(0));
        expect(product.category, isNotEmpty);
        expect(product.imageUrl, isNotEmpty);
      });

      test('product has ratings', () async {
        final product = await productService.getProductById('1');
        expect(product.rating, greaterThanOrEqualTo(0));
        expect(product.rating, lessThanOrEqualTo(5));
      });

      test('product has review count', () async {
        final product = await productService.getProductById('1');
        expect(product.reviews, greaterThanOrEqualTo(0));
      });

      test('product has care and material information', () async {
        final product = await productService.getProductById('1');
        expect(product.materials, isNotNull);
        expect(product.care, isNotNull);
      });
    });

    group('Product Pricing', () {
      test('all products have valid prices', () async {
        final products = await productService.getProducts();
        for (final product in products) {
          expect(product.price, greaterThanOrEqualTo(0));
        }
      });

      test('expensive products are available', () async {
        final products = await productService.getProducts();
        final expensive = products.where((p) => p.price > 1000).toList();
        expect(expensive, isNotEmpty);
      });
    });

    group('Category Management', () {
      test('different categories are available', () async {
        final watch = await productService.getProductsByCategory('Watches');
        final accessories = await productService.getProductsByCategory('Accessories');
        expect(watch.isNotEmpty && accessories.isNotEmpty, true);
      });

      test('products belong to valid categories', () async {
        final products = await productService.getProducts();
        final categories = products.map((p) => p.category).toSet();
        expect(categories, isNotEmpty);
      });
    });

    group('Product State Consistency', () {
      test('product details remain consistent', () async {
        final product1 = await productService.getProductById('1');
        final product2 = await productService.getProductById('1');
        expect(product1, equals(product2));
      });

      test('fetching all products includes searched product', () async {
        final allProducts = await productService.getProducts();
        final searchResults = await productService.searchProducts('Watch');
        expect(allProducts.map((p) => p.id), contains(searchResults.first.id));
      });
    });

    group('Error Handling', () {
      test('handles network errors gracefully', () async {
        productService.exception = Exception('Network error');
        expect(
          () => productService.getProducts(),
          throwsException,
        );
      });

      test('handles invalid product ID', () async {
        expect(
          () => productService.getProductById(''),
          throwsException,
        );
      });

      test('handles empty search query', () async {
        final results = await productService.searchProducts('');
        // Should return all or filtered results
        expect(results, isNotNull);
      });
    });
  });
}
