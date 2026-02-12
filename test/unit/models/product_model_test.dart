import 'package:flutter_test/flutter_test.dart';
import 'package:luxefinds_client/models/product.dart';

void main() {
  group('Product Model Tests', () {
    final testProduct = Product(
      id: '1',
      name: 'Luxury Watch',
      description: 'Premium Swiss Watch',
      price: 2500.0,
      category: 'Watches',
      imageUrl: 'https://example.com/watch.jpg',
      materials: ['Stainless Steel', 'Leather'],
      care: ['Clean with soft cloth'],
      inStock: true,
      stock: 10,
      rating: 4.5,
      reviews: 25,
    );

    group('Initialization', () {
      test('creates product with all fields', () {
        expect(testProduct.id, equals('1'));
        expect(testProduct.name, equals('Luxury Watch'));
        expect(testProduct.price, equals(2500.0));
        expect(testProduct.inStock, equals(true));
        expect(testProduct.stock, equals(10));
      });

      test('creates out-of-stock product', () {
        final outOfStock = Product(
          id: '2',
          name: 'Limited Item',
          description: 'Exclusive product',
          price: 5000.0,
          category: 'Bags',
          imageUrl: 'https://example.com/bag.jpg',
          materials: ['Leather'],
          care: ['Professional care'],
          inStock: false,
          stock: 0,
          rating: 5.0,
          reviews: 10,
        );
        expect(outOfStock.inStock, equals(false));
        expect(outOfStock.stock, equals(0));
      });
    });

    group('JSON Serialization', () {
      test('converts product to JSON', () {
        final json = testProduct.toJson();
        expect(json['id'], equals('1'));
        expect(json['name'], equals('Luxury Watch'));
        expect(json['price'], equals(2500.0));
        expect(json['category'], equals('Watches'));
      });

      test('creates product from JSON', () {
        final json = {
          'id': '3',
          'name': 'Designer Sunglasses',
          'description': 'UV protection',
          'price': 850.0,
          'category': 'Accessories',
          'imageUrl': 'https://example.com/sunglasses.jpg',
          'materials': ['Acetate'],
          'care': ['Store in case'],
          'inStock': true,
          'stock': 15,
          'rating': 4.8,
          'reviews': 42,
        };
        final product = Product.fromJson(json);
        expect(product.id, equals('3'));
        expect(product.name, equals('Designer Sunglasses'));
        expect(product.price, equals(850.0));
      });

      test('round-trip JSON serialization preserves data', () {
        final json = testProduct.toJson();
        final newProduct = Product.fromJson(json);
        expect(newProduct.id, equals(testProduct.id));
        expect(newProduct.name, equals(testProduct.name));
        expect(newProduct.price, equals(testProduct.price));
        expect(newProduct.materials, equals(testProduct.materials));
      });
    });

    group('Equality', () {
      test('products with same data are equal', () {
        final product1 = Product(
          id: '1',
          name: 'Luxury Watch',
          description: 'Premium Swiss Watch',
          price: 2500.0,
          category: 'Watches',
          imageUrl: 'https://example.com/watch.jpg',
          materials: ['Stainless Steel', 'Leather'],
          care: ['Clean with soft cloth'],
          inStock: true,
          stock: 10,
          rating: 4.5,
          reviews: 25,
        );
        final product2 = Product(
          id: '1',
          name: 'Luxury Watch',
          description: 'Premium Swiss Watch',
          price: 2500.0,
          category: 'Watches',
          imageUrl: 'https://example.com/watch.jpg',
          materials: ['Stainless Steel', 'Leather'],
          care: ['Clean with soft cloth'],
          inStock: true,
          stock: 10,
          rating: 4.5,
          reviews: 25,
        );
        expect(product1, equals(product2));
      });

      test('products with different prices are not equal', () {
        final product1 = testProduct;
        final product2 = testProduct.copyWith(price: 3000.0);
        expect(product1, isNot(equals(product2)));
      });
    });

    group('Stock Status', () {
      test('inStock is true when stock > 0', () {
        expect(testProduct.inStock, equals(true));
        expect(testProduct.stock, greaterThan(0));
      });

      test('inStock is false when stock = 0', () {
        final outOfStock = testProduct.copyWith(stock: 0, inStock: false);
        expect(outOfStock.inStock, equals(false));
        expect(outOfStock.stock, equals(0));
      });
    });

    group('Price Formatting', () {
      test('handles high prices', () {
        final expensiveProduct = testProduct.copyWith(price: 10000.0);
        expect(expensiveProduct.price, equals(10000.0));
      });

      test('handles low prices', () {
        final cheapProduct = testProduct.copyWith(price: 9.99);
        expect(cheapProduct.price, equals(9.99));
      });

      test('handles zero price edge case', () {
        final freeProduct = testProduct.copyWith(price: 0.0);
        expect(freeProduct.price, equals(0.0));
      });
    });

    group('Rating & Reviews', () {
      test('ratings are within valid range', () {
        expect(testProduct.rating, greaterThanOrEqualTo(0));
        expect(testProduct.rating, lessThanOrEqualTo(5));
      });

      test('reviews count is non-negative', () {
        expect(testProduct.reviews, greaterThanOrEqualTo(0));
      });

      test('handles no reviews', () {
        final noReviews = testProduct.copyWith(reviews: 0, rating: 0);
        expect(noReviews.reviews, equals(0));
      });
    });

    group('Materials and Care', () {
      test('materials list is preserved', () {
        expect(testProduct.materials, equals(['Stainless Steel', 'Leather']));
      });

      test('care instructions are preserved', () {
        expect(testProduct.care, equals(['Clean with soft cloth']));
      });

      test('handles empty materials list', () {
        final noMaterials = testProduct.copyWith(materials: []);
        expect(noMaterials.materials, isEmpty);
      });

      test('handles empty care list', () {
        final noCare = testProduct.copyWith(care: []);
        expect(noCare.care, isEmpty);
      });
    });

    group('Immutability', () {
      test('copyWith creates new product with updated field', () {
        final updatedProduct = testProduct.copyWith(name: 'Updated Watch');
        expect(updatedProduct.name, equals('Updated Watch'));
        expect(updatedProduct.id, equals(testProduct.id));
        expect(updatedProduct.price, equals(testProduct.price));
      });

      test('original product is unchanged after copyWith', () {
        final original = testProduct;
        final updated = testProduct.copyWith(stock: 5);
        expect(original.stock, equals(10));
        expect(updated.stock, equals(5));
      });
    });
  });
}
