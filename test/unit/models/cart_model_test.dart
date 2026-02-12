import 'package:flutter_test/flutter_test.dart';
import 'package:luxefinds_client/models/cart.dart';

void main() {
  group('Cart Model Tests', () {
    final cartItem1 = CartItem(
      productId: '1',
      name: 'Luxury Watch',
      price: 2500.0,
      quantity: 1,
      imageUrl: 'https://example.com/watch.jpg',
    );

    final cartItem2 = CartItem(
      productId: '2',
      name: 'Designer Sunglasses',
      price: 850.0,
      quantity: 2,
      imageUrl: 'https://example.com/sunglasses.jpg',
    );

    final testCart = Cart(
      id: 'cart-123',
      userId: '123',
      items: [cartItem1, cartItem2],
      totalPrice: 2500.0 + (850.0 * 2),
      totalItems: 3,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    );

    group('CartItem Tests', () {
      test('creates cart item with correct data', () {
        expect(cartItem1.productId, equals('1'));
        expect(cartItem1.name, equals('Luxury Watch'));
        expect(cartItem1.price, equals(2500.0));
        expect(cartItem1.quantity, equals(1));
      });

      test('calculates item total correctly', () {
        expect(cartItem2.quantity * cartItem2.price, equals(1700.0));
      });

      test('handles quantity of 1', () {
        final singleItem = cartItem1.copyWith(quantity: 1);
        expect(singleItem.quantity, equals(1));
      });

      test('handles large quantities', () {
        final manyItems = cartItem1.copyWith(quantity: 100);
        expect(manyItems.quantity, equals(100));
      });
    });

    group('CartItem JSON Serialization', () {
      test('converts cart item to JSON', () {
        final json = cartItem1.toJson();
        expect(json['productId'], equals('1'));
        expect(json['name'], equals('Luxury Watch'));
        expect(json['price'], equals(2500.0));
        expect(json['quantity'], equals(1));
      });

      test('creates cart item from JSON', () {
        final json = {
          'productId': '3',
          'name': 'Designer Bag',
          'price': 3200.0,
          'quantity': 1,
          'imageUrl': 'https://example.com/bag.jpg',
        };
        final item = CartItem.fromJson(json);
        expect(item.productId, equals('3'));
        expect(item.name, equals('Designer Bag'));
        expect(item.price, equals(3200.0));
      });

      test('round-trip JSON serialization preserves data', () {
        final json = cartItem1.toJson();
        final newItem = CartItem.fromJson(json);
        expect(newItem.productId, equals(cartItem1.productId));
        expect(newItem.name, equals(cartItem1.name));
        expect(newItem.price, equals(cartItem1.price));
        expect(newItem.quantity, equals(cartItem1.quantity));
      });
    });

    group('Cart Initialization', () {
      test('creates cart with items', () {
        expect(testCart.id, equals('cart-123'));
        expect(testCart.userId, equals('123'));
        expect(testCart.items.length, equals(2));
        expect(testCart.totalItems, equals(3));
        expect(testCart.totalPrice, equals(4200.0));
      });

      test('creates empty cart', () {
        final emptyCart = Cart(
          id: 'cart-456',
          userId: '456',
          items: [],
          totalPrice: 0,
          totalItems: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(emptyCart.items, isEmpty);
        expect(emptyCart.totalItems, equals(0));
        expect(emptyCart.totalPrice, equals(0));
      });
    });

    group('Cart JSON Serialization', () {
      test('converts cart to JSON', () {
        final json = testCart.toJson();
        expect(json['id'], equals('cart-123'));
        expect(json['userId'], equals('123'));
        expect(json['totalItems'], equals(3));
        expect(json['totalPrice'], equals(4200.0));
      });

      test('creates cart from JSON', () {
        final json = {
          'id': 'cart-789',
          'userId': '789',
          'items': [
            {
              'productId': '1',
              'name': 'Luxury Watch',
              'price': 2500.0,
              'quantity': 1,
              'imageUrl': 'https://example.com/watch.jpg',
            },
          ],
          'totalPrice': 2500.0,
          'totalItems': 1,
          'createdAt': '2024-01-15T00:00:00.000Z',
          'updatedAt': '2024-01-15T00:00:00.000Z',
        };
        final cart = Cart.fromJson(json);
        expect(cart.id, equals('cart-789'));
        expect(cart.items.length, equals(1));
        expect(cart.totalPrice, equals(2500.0));
      });

      test('round-trip JSON serialization preserves data', () {
        final json = testCart.toJson();
        final newCart = Cart.fromJson(json);
        expect(newCart.id, equals(testCart.id));
        expect(newCart.userId, equals(testCart.userId));
        expect(newCart.items.length, equals(testCart.items.length));
        expect(newCart.totalPrice, equals(testCart.totalPrice));
        expect(newCart.totalItems, equals(testCart.totalItems));
      });
    });

    group('Cart Equality', () {
      test('carts with same data are equal', () {
        final cart1 = testCart;
        final cart2 = Cart(
          id: 'cart-123',
          userId: '123',
          items: [cartItem1, cartItem2],
          totalPrice: 4200.0,
          totalItems: 3,
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );
        expect(cart1, equals(cart2));
      });

      test('carts with different totals are not equal', () {
        final cart2 = testCart.copyWith(totalPrice: 5000.0);
        expect(testCart, isNot(equals(cart2)));
      });
    });

    group('Cart Mutations', () {
      test('copyWith creates new cart with updated field', () {
        final updatedCart = testCart.copyWith(totalPrice: 5000.0);
        expect(updatedCart.totalPrice, equals(5000.0));
        expect(testCart.totalPrice, equals(4200.0)); // original unchanged
      });

      test('copyWith can update items list', () {
        final newItems = [cartItem1];
        final updatedCart = testCart.copyWith(items: newItems);
        expect(updatedCart.items.length, equals(1));
        expect(testCart.items.length, equals(2)); // original unchanged
      });
    });

    group('Cart Total Calculations', () {
      test('calculates total price correctly with multiple items', () {
        final expectedTotal = (cartItem1.price * cartItem1.quantity) +
            (cartItem2.price * cartItem2.quantity);
        expect(testCart.totalPrice, equals(expectedTotal));
      });

      test('calculates total items correctly', () {
        final expectedTotal = cartItem1.quantity + cartItem2.quantity;
        expect(testCart.totalItems, equals(expectedTotal));
      });

      test('handles empty cart totals', () {
        final emptyCart = Cart(
          id: 'empty',
          userId: '123',
          items: [],
          totalPrice: 0,
          totalItems: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(emptyCart.totalPrice, equals(0));
        expect(emptyCart.totalItems, equals(0));
      });
    });
  });
}
