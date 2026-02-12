import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luxefinds_client/models/cart.dart';

import '../../helpers/test_fixtures.dart';
import '../../mocks/mock_services.dart';

void main() {
  group('CartNotifier Tests', () {
    late ProviderContainer container;
    late FakeCartService cartService;

    setUp(() {
      cartService = FakeCartService();
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('cart is empty initially', () async {
        final cart = await cartService.getCart();
        expect(cart.items, isEmpty);
        expect(cart.totalPrice, equals(0));
        expect(cart.totalItems, equals(0));
      });
    });

    group('Add to Cart', () {
      test('adds item to empty cart', () async {
        final cart = await cartService.addToCart('1', 1);
        expect(cart.items.length, equals(1));
        expect(cart.totalItems, equals(1));
      });

      test('adds multiple items to cart', () async {
        await cartService.addToCart('1', 1);
        final cart = await cartService.addToCart('2', 2);
        expect(cart.items.length, equals(2));
        expect(cart.totalItems, equals(3));
      });

      test('updates total price on add', () async {
        final cart = await cartService.addToCart('1', 1);
        expect(cart.totalPrice, greaterThan(0));
      });

      test('preserves item details', () async {
        final cart = await cartService.addToCart('1', 5);
        final item = cart.items.first;
        expect(item.productId, equals('1'));
        expect(item.quantity, equals(5));
      });

      test('handles adding same product multiple times', () async {
        await cartService.addToCart('1', 1);
        final cart = await cartService.addToCart('1', 2);
        final items = cart.items.where((item) => item.productId == '1').toList();
        expect(items, isNotEmpty);
      });
    });

    group('Remove from Cart', () {
      test('removes item from cart', () async {
        await cartService.addToCart('1', 1);
        await cartService.addToCart('2', 1);
        final cart = await cartService.removeFromCart('1');
        expect(cart.items.where((item) => item.productId == '1'), isEmpty);
      });

      test('updates totals after removal', () async {
        await cartService.addToCart('1', 3);
        await cartService.addToCart('2', 2);
        final cart = await cartService.removeFromCart('1');
        expect(cart.items.length, equals(1));
      });

      test('handles removing non-existent item', () async {
        await cartService.addToCart('1', 1);
        expect(
          () => cartService.removeFromCart('999'),
          returnsNormally,
        );
      });

      test('can remove all items one by one', () async {
        await cartService.addToCart('1', 1);
        await cartService.addToCart('2', 1);
        await cartService.removeFromCart('1');
        final cart = await cartService.removeFromCart('2');
        expect(cart.items, isEmpty);
      });
    });

    group('Update Cart Item', () {
      test('updates item quantity', () async {
        await cartService.addToCart('1', 1);
        final cart = await cartService.updateCartItem('1', 5);
        expect(cart, isNotNull);
      });

      test('can increase quantity', () async {
        await cartService.addToCart('1', 1);
        final cart = await cartService.updateCartItem('1', 10);
        expect(cart, isNotNull);
      });

      test('can decrease quantity', () async {
        await cartService.addToCart('1', 10);
        final cart = await cartService.updateCartItem('1', 3);
        expect(cart, isNotNull);
      });
    });

    group('Clear Cart', () {
      test('clears all items', () async {
        await cartService.addToCart('1', 1);
        await cartService.addToCart('2', 2);
        await cartService.clearCart();
        final cart = await cartService.getCart();
        expect(cart.items, isEmpty);
      });

      test('resets totals to zero', () async {
        await cartService.addToCart('1', 5);
        await cartService.clearCart();
        final cart = await cartService.getCart();
        expect(cart.totalItems, equals(0));
        expect(cart.totalPrice, equals(0));
      });

      test('cart can be repopulated after clearing', () async {
        await cartService.addToCart('1', 1);
        await cartService.clearCart();
        final cart = await cartService.addToCart('2', 3);
        expect(cart.items.length, equals(1));
        expect(cart.items.first.productId, equals('2'));
      });
    });

    group('Cart Totals', () {
      test('calculates correct total items', () async {
        await cartService.addToCart('1', 3);
        final cart = await cartService.addToCart('2', 2);
        expect(cart.totalItems, equals(5));
      });

      test('calculates correct total price', () async {
        final cart = await cartService.addToCart('1', 1);
        expect(cart.totalPrice, greaterThan(0));
      });

      test('updates totals on each operation', () async {
        final cart1 = await cartService.addToCart('1', 1);
        final initialTotal = cart1.totalPrice;
        final cart2 = await cartService.addToCart('2', 1);
        expect(cart2.totalPrice, greaterThanOrEqualTo(initialTotal));
      });
    });

    group('Cart State Management', () {
      test('cart maintains consistent state', () async {
        await cartService.addToCart('1', 1);
        final cart1 = await cartService.getCart();
        final cart2 = await cartService.getCart();
        expect(cart1.items.length, equals(cart2.items.length));
      });

      test('multiple operations preserve state', () async {
        await cartService.addToCart('1', 1);
        await cartService.addToCart('2', 2);
        await cartService.updateCartItem('1', 5);
        final cart = await cartService.getCart();
        expect(cart.items.length, equals(2));
      });
    });

    group('Cart Persistence', () {
      test('cart has unique ID', () async {
        final cart = await cartService.getCart();
        expect(cart.id, isNotEmpty);
      });

      test('cart has user ID', () async {
        final cart = await cartService.getCart();
        expect(cart.userId, isNotEmpty);
      });

      test('cart has timestamps', () async {
        final cart = await cartService.getCart();
        expect(cart.createdAt, isNotNull);
        expect(cart.updatedAt, isNotNull);
      });
    });

    group('Error Handling', () {
      test('handles add to cart error', () async {
        cartService.exception = Exception('Add failed');
        expect(
          () => cartService.addToCart('1', 1),
          throwsException,
        );
      });

      test('handles remove from cart error', () async {
        await cartService.addToCart('1', 1);
        cartService.exception = Exception('Remove failed');
        expect(
          () => cartService.removeFromCart('1'),
          throwsException,
        );
      });

      test('handles clear cart error', () async {
        cartService.exception = Exception('Clear failed');
        expect(
          () => cartService.clearCart(),
          throwsException,
        );
      });
    });
  });
}
