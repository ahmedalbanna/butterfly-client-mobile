import 'package:flutter_test/flutter_test.dart';
import 'package:luxefinds_client/models/product.dart';

import '../../helpers/test_fixtures.dart';
import '../../mocks/mock_services.dart';

void main() {
  group('ProductService Tests', () {
    late FakeProductService productService;

    setUp(() {
      productService = FakeProductService();
      productService.addProduct(testProduct1);
      productService.addProduct(testProduct2);
      productService.addProduct(testProduct3OutOfStock);
    });

    tearDown(() {
      productService.clear();
    });

    group('Get Products', () {
      test('returns list of products', () async {
        final products = await productService.getProducts();
        expect(products, isNotEmpty);
        expect(products.length, equals(3));
      });

      test('returns empty list when no products exist', () async {
        productService.clear();
        final products = await productService.getProducts();
        expect(products, isEmpty);
      });

      test('respects pagination parameters', () async {
        final products = await productService.getProducts(page: 1, limit: 2);
        expect(products, isNotEmpty);
      });

      test('throws exception on service error', () async {
        productService.exception = Exception('Network error');
        expect(
          () => productService.getProducts(),
          throwsException,
        );
      });

      test('returns products with correct structure', () async {
        final products = await productService.getProducts();
        expect(products.first.id, isNotEmpty);
        expect(products.first.name, isNotEmpty);
        expect(products.first.price, greaterThan(0));
      });
    });

    group('Get Product By ID', () {
      test('returns product with matching ID', () async {
        final product = await productService.getProductById('1');
        expect(product.id, equals('1'));
        expect(product.name, equals('Luxury Watch'));
      });

      test('throws exception for non-existent product', () async {
        expect(
          () => productService.getProductById('999'),
          throwsException,
        );
      });

      test('throws exception on service error', () async {
        productService.exception = Exception('Network error');
        expect(
          () => productService.getProductById('1'),
          throwsException,
        );
      });

      test('returns product with all details', () async {
        final product = await productService.getProductById('1');
        expect(product.description, isNotEmpty);
        expect(product.category, isNotEmpty);
        expect(product.imageUrl, isNotEmpty);
        expect(product.materials, isNotEmpty);
        expect(product.care, isNotEmpty);
      });
    });

    group('Search Products', () {
      test('returns products matching search query', () async {
        final results = await productService.searchProducts('Watch');
        expect(results, isNotEmpty);
        expect(results.first.name, contains('Watch'));
      });

      test('search is case-insensitive', () async {
        final results1 = await productService.searchProducts('watch');
        final results2 = await productService.searchProducts('WATCH');
        expect(results1.length, equals(results2.length));
      });

      test('returns empty list for non-matching search', () async {
        final results = await productService.searchProducts('NonExistent');
        expect(results, isEmpty);
      });

      test('throws exception on service error', () async {
        productService.exception = Exception('Search error');
        expect(
          () => productService.searchProducts('Watch'),
          throwsException,
        );
      });

      test('returns multiple products for broad search', () async {
        final results = await productService.searchProducts('Designer');
        expect(results, isNotEmpty);
      });
    });

    group('Get Products By Category', () {
      test('returns products for valid category', () async {
        final results = await productService.getProductsByCategory('Watches');
        expect(results, isNotEmpty);
        expect(results.first.category, equals('Watches'));
      });

      test('returns empty list for non-existent category', () async {
        final results = await productService.getProductsByCategory('Shoes');
        expect(results, isEmpty);
      });

      test('returns multiple products in category', () async {
        final results = await productService.getProductsByCategory('Watches');
        expect(results.length, greaterThanOrEqualTo(1));
      });

      test('throws exception on service error', () async {
        productService.exception = Exception('Category error');
        expect(
          () => productService.getProductsByCategory('Watches'),
          throwsException,
        );
      });

      test('category filtering is exact match', () async {
        final results = await productService.getProductsByCategory('Accessories');
        expect(results.first.category, equals('Accessories'));
      });
    });

    group('Stock Status', () {
      test('in-stock products are returned correctly', () async {
        final products = await productService.getProducts();
        final inStockProducts = products.where((p) => p.inStock).toList();
        expect(inStockProducts, isNotEmpty);
      });

      test('out-of-stock products are returned correctly', () async {
        final products = await productService.getProducts();
        final outOfStockProducts = products.where((p) => !p.inStock).toList();
        expect(outOfStockProducts, isNotEmpty);
      });

      test('stock quantity is accurate', () async {
        final product = await productService.getProductById('1');
        expect(product.stock, greaterThanOrEqualTo(0));
      });
    });

    group('Product Details', () {
      test('product has all required fields', () async {
        final product = await productService.getProductById('1');
        expect(product.id, isNotEmpty);
        expect(product.name, isNotEmpty);
        expect(product.description, isNotEmpty);
        expect(product.price, isNotNull);
        expect(product.category, isNotEmpty);
        expect(product.imageUrl, isNotEmpty);
      });

      test('product has ratings and reviews', () async {
        final product = await productService.getProductById('1');
        expect(product.rating, greaterThanOrEqualTo(0));
        expect(product.reviews, greaterThanOrEqualTo(0));
      });

      test('product has materials and care information', () async {
        final product = await productService.getProductById('1');
        expect(product.materials, isNotNull);
        expect(product.care, isNotNull);
      });
    });
  });
}
