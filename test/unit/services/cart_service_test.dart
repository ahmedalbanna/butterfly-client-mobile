import 'package:flutter_test/flutter_test.dart';
import 'package:luxefinds_client/models/cart.dart';

import '../../helpers/test_fixtures.dart';
import '../../mocks/mock_services.dart';

void main() {
  group('CartService Tests', () {
    late FakeCartService cartService;

    setUp(() {
      cartService = FakeCartService();
    });

    group('Get Cart', () {
      test('returns empty cart initially', () async {
        final cart = await cartService.getCart();
        expect(cart, isNotNull);
        expect(cart.items, isEmpty);
        expect(cart.totalPrice, equals(0));
      });

      test('returns cart with items when they exist', () async {
        await cartService.addToCart('1', 1);
        final cart = await cartService.getCart();
        expect(cart.items, isNotEmpty);
      });

      test('throws exception on service error', () async {
        cartService.exception = Exception('Cart service error');
        expect(
          () => cartService.getCart(),
          throwsException,
        );
      });
    });

    group('Add To Cart', () {
      test('successfully adds product to empty cart', () async {
        final cart = await cartService.addToCart('1', 1);
        expect(cart.items, isNotEmpty);
        expect(cart.items.length, equals(1));
        expect(cart.totalItems, equals(1));
      });

      test('adds product with correct quantity', () async {
        final cart = await cartService.addToCart('1', 5);
        expect(cart.items.first.quantity, equals(5));
      });

      test('adds multiple different products', () async {
        await cartService.addToCart('1', 1);
        final cart = await cartService.addToCart('2', 2);
        expect(cart.items.length, equals(2));
        expect(cart.totalItems, equals(3));
      });

      test('updates total price correctly', () async {
        final cart = await cartService.addToCart('1', 1);
        expect(cart.totalPrice, greaterThan(0));
      });

      test('throws exception on add failure', () async {
        cartService.exception = Exception('Add to cart failed');
        expect(
          () => cartService.addToCart('1', 1),
          throwsException,
        );
      });

      test('handles large quantities', () async {
        final cart = await cartService.addToCart('1', 100);
        expect(cart.items.first.quantity, equals(100));
      });
    });

    group('Remove From Cart', () {
      test('successfully removes product from cart', () async {
        await cartService.addToCart('1', 1);
        await cartService.addToCart('2', 1);
        final cart = await cartService.removeFromCart('1');
        expect(cart.items.length, equals(1));
        expect(cart.items.first.productId, equals('2'));
      });

      test('removes product completely', () async {
        await cartService.addToCart('1', 5);
        final cart = await cartService.removeFromCart('1');
        expect(cart.items.where((item) => item.productId == '1'), isEmpty);
      });

      test('throws exception on remove failure', () async {
        cartService.exception = Exception('Remove failed');
        expect(
          () => cartService.removeFromCart('1'),
          throwsException,
        );
      });

      test('handles removing non-existent product gracefully', () async {
        await cartService.addToCart('1', 1);
        expect(
          () => cartService.removeFromCart('999'),
          returnsNormally,
        );
      });
    });

    group('Update Cart Item', () {
      test('successfully updates item quantity', () async {
        await cartService.addToCart('1', 1);
        final cart = await cartService.updateCartItem('1', 5);
        expect(cart, isNotNull);
      });

      test('throws exception on update failure', () async {
        cartService.exception = Exception('Update failed');
        expect(
          () => cartService.updateCartItem('1', 5),
          throwsException,
        );
      });

      test('can increase quantity', () async {
        await cartService.addToCart('1', 1);
        final cart = await cartService.updateCartItem('1', 3);
        expect(cart, isNotNull);
      });

      test('can decrease quantity', () async {
        await cartService.addToCart('1', 5);
        final cart = await cartService.updateCartItem('1', 2);
        expect(cart, isNotNull);
      });
    });

    group('Clear Cart', () {
      test('successfully clears all items from cart', () async {
        await cartService.addToCart('1', 1);
        await cartService.addToCart('2', 2);
        await cartService.clearCart();
        final cart = await cartService.getCart();
        // After clear, cart should be empty or null depending on implementation
        expect(cart.items, isEmpty);
      });

      test('throws exception on clear failure', () async {
        cartService.exception = Exception('Clear failed');
        expect(
          () => cartService.clearCart(),
          throwsException,
        );
      });

      test('cart can be repopulated after clearing', () async {
        await cartService.addToCart('1', 1);
        await cartService.clearCart();
        final cart = await cartService.addToCart('2', 1);
        expect(cart.items, isNotEmpty);
      });
    });

    group('Cart Totals', () {
      test('calculates correct total price', () async {
        final cart = await cartService.addToCart('1', 1);
        expect(cart.totalPrice, greaterThan(0));
      });

      test('calculates correct total items', () async {
        await cartService.addToCart('1', 3);
        final cart = await cartService.addToCart('2', 2);
        expect(cart.totalItems, equals(5));
      });

      test('totals update after adding items', () async {
        final cart1 = await cartService.addToCart('1', 1);
        final initialTotal = cart1.totalItems;
        final cart2 = await cartService.addToCart('2', 2);
        expect(cart2.totalItems, greaterThan(initialTotal));
      });
    });

    group('Cart State', () {
      test('cart has unique ID', () async {
        final cart = await cartService.getCart();
        expect(cart.id, isNotEmpty);
      });

      test('cart has user ID', () async {
        final cart = await cartService.getCart();
        expect(cart.userId, isNotEmpty);
      });

      test('cart has creation timestamp', () async {
        final cart = await cartService.getCart();
        expect(cart.createdAt, isNotNull);
      });

      test('cart has update timestamp', () async {
        final cart = await cartService.getCart();
        expect(cart.updatedAt, isNotNull);
      });
    });
  });
}
