import 'package:flutter_test/flutter_test.dart';
import 'package:luxefinds_client/models/order.dart';

void main() {
  group('Order Model Tests', () {
    final orderItem1 = OrderItem(
      productId: '1',
      name: 'Luxury Watch',
      price: 2500.0,
      quantity: 1,
      imageUrl: 'https://example.com/watch.jpg',
    );

    final orderItem2 = OrderItem(
      productId: '2',
      name: 'Designer Sunglasses',
      price: 850.0,
      quantity: 2,
      imageUrl: 'https://example.com/sunglasses.jpg',
    );

    final testOrder = Order(
      id: 'order-123',
      userId: '123',
      items: [orderItem1, orderItem2],
      totalPrice: 2500.0 + (850.0 * 2),
      status: 'confirmed',
      shippingAddress: '123 Main St, New York, NY 10001',
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    );

    group('OrderItem Tests', () {
      test('creates order item with correct data', () {
        expect(orderItem1.productId, equals('1'));
        expect(orderItem1.name, equals('Luxury Watch'));
        expect(orderItem1.price, equals(2500.0));
        expect(orderItem1.quantity, equals(1));
      });

      test('calculates item total correctly', () {
        expect(orderItem2.quantity * orderItem2.price, equals(1700.0));
      });

      test('handles quantity of 1', () {
        expect(orderItem1.quantity, equals(1));
      });

      test('handles large quantities', () {
        final manyItems = orderItem2.copyWith(quantity: 50);
        expect(manyItems.quantity, equals(50));
        expect(manyItems.price, equals(850.0)); // price per unit unchanged
      });
    });

    group('OrderItem JSON Serialization', () {
      test('converts order item to JSON', () {
        final json = orderItem1.toJson();
        expect(json['productId'], equals('1'));
        expect(json['name'], equals('Luxury Watch'));
        expect(json['price'], equals(2500.0));
        expect(json['quantity'], equals(1));
      });

      test('creates order item from JSON', () {
        final json = {
          'productId': '3',
          'name': 'Designer Bag',
          'price': 3200.0,
          'quantity': 1,
          'imageUrl': 'https://example.com/bag.jpg',
        };
        final item = OrderItem.fromJson(json);
        expect(item.productId, equals('3'));
        expect(item.name, equals('Designer Bag'));
        expect(item.price, equals(3200.0));
      });

      test('round-trip JSON serialization preserves data', () {
        final json = orderItem1.toJson();
        final newItem = OrderItem.fromJson(json);
        expect(newItem.productId, equals(orderItem1.productId));
        expect(newItem.name, equals(orderItem1.name));
        expect(newItem.price, equals(orderItem1.price));
        expect(newItem.quantity, equals(orderItem1.quantity));
      });
    });

    group('Order Initialization', () {
      test('creates order with all fields', () {
        expect(testOrder.id, equals('order-123'));
        expect(testOrder.userId, equals('123'));
        expect(testOrder.items.length, equals(2));
        expect(testOrder.totalPrice, equals(4200.0));
        expect(testOrder.status, equals('confirmed'));
        expect(testOrder.shippingAddress, isNotEmpty);
      });

      test('creates order with different status', () {
        final processingOrder = testOrder.copyWith(status: 'processing');
        expect(processingOrder.status, equals('processing'));
      });

      test('creates order with shipped status', () {
        final shippedOrder = testOrder.copyWith(status: 'shipped');
        expect(shippedOrder.status, equals('shipped'));
      });

      test('creates order with cancelled status', () {
        final cancelledOrder = testOrder.copyWith(status: 'cancelled');
        expect(cancelledOrder.status, equals('cancelled'));
      });
    });

    group('Order JSON Serialization', () {
      test('converts order to JSON', () {
        final json = testOrder.toJson();
        expect(json['id'], equals('order-123'));
        expect(json['userId'], equals('123'));
        expect(json['totalPrice'], equals(4200.0));
        expect(json['status'], equals('confirmed'));
        expect(json['shippingAddress'], isNotEmpty);
      });

      test('creates order from JSON', () {
        final json = {
          'id': 'order-456',
          'userId': '456',
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
          'status': 'confirmed',
          'shippingAddress': '456 Oak Ave, Los Angeles, CA 90001',
          'createdAt': '2024-01-15T00:00:00.000Z',
          'updatedAt': '2024-01-15T00:00:00.000Z',
        };
        final order = Order.fromJson(json);
        expect(order.id, equals('order-456'));
        expect(order.userId, equals('456'));
        expect(order.items.length, equals(1));
        expect(order.totalPrice, equals(2500.0));
      });

      test('round-trip JSON serialization preserves data', () {
        final json = testOrder.toJson();
        final newOrder = Order.fromJson(json);
        expect(newOrder.id, equals(testOrder.id));
        expect(newOrder.userId, equals(testOrder.userId));
        expect(newOrder.items.length, equals(testOrder.items.length));
        expect(newOrder.totalPrice, equals(testOrder.totalPrice));
        expect(newOrder.status, equals(testOrder.status));
      });
    });

    group('Order Equality', () {
      test('orders with same data are equal', () {
        final order1 = testOrder;
        final order2 = Order(
          id: 'order-123',
          userId: '123',
          items: [orderItem1, orderItem2],
          totalPrice: 4200.0,
          status: 'confirmed',
          shippingAddress: '123 Main St, New York, NY 10001',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );
        expect(order1, equals(order2));
      });

      test('orders with different status are not equal', () {
        final order2 = testOrder.copyWith(status: 'shipped');
        expect(testOrder, isNot(equals(order2)));
      });

      test('orders with different shipping address are not equal', () {
        final order2 = testOrder.copyWith(shippingAddress: '999 Different St');
        expect(testOrder, isNot(equals(order2)));
      });
    });

    group('Order Status', () {
      test('valid order statuses', () {
        final validStatuses = ['confirmed', 'processing', 'shipped', 'delivered', 'cancelled'];
        for (final status in validStatuses) {
          final order = testOrder.copyWith(status: status);
          expect(order.status, equals(status));
        }
      });

      test('order can transition from confirmed to processing', () {
        final confirmedOrder = testOrder;
        final processingOrder = confirmedOrder.copyWith(status: 'processing');
        expect(confirmedOrder.status, equals('confirmed'));
        expect(processingOrder.status, equals('processing'));
      });

      test('order can be cancelled', () {
        final cancelledOrder = testOrder.copyWith(status: 'cancelled');
        expect(cancelledOrder.status, equals('cancelled'));
      });
    });

    group('Order Mutations', () {
      test('copyWith creates new order with updated field', () {
        final updatedOrder = testOrder.copyWith(status: 'shipped');
        expect(updatedOrder.status, equals('shipped'));
        expect(testOrder.status, equals('confirmed')); // original unchanged
      });

      test('copyWith can update multiple fields', () {
        final updatedOrder = testOrder.copyWith(
          status: 'delivered',
          totalPrice: 5000.0,
        );
        expect(updatedOrder.status, equals('delivered'));
        expect(updatedOrder.totalPrice, equals(5000.0));
        expect(testOrder.status, equals('confirmed')); // original unchanged
      });
    });

    group('Order Total Calculations', () {
      test('calculates total price correctly with multiple items', () {
        final expectedTotal = (orderItem1.price * orderItem1.quantity) +
            (orderItem2.price * orderItem2.quantity);
        expect(testOrder.totalPrice, equals(expectedTotal));
      });

      test('handles single item order', () {
        final singleItemOrder = testOrder.copyWith(items: [orderItem1]);
        expect(singleItemOrder.totalPrice, equals(2500.0));
      });

      test('handles large order total', () {
        final largeOrder = testOrder.copyWith(totalPrice: 50000.0);
        expect(largeOrder.totalPrice, equals(50000.0));
      });
    });

    group('Order Timestamps', () {
      test('order has creation timestamp', () {
        expect(testOrder.createdAt, isNotNull);
      });

      test('order has update timestamp', () {
        expect(testOrder.updatedAt, isNotNull);
      });

      test('update timestamp can be changed', () {
        final now = DateTime.now();
        final updatedOrder = testOrder.copyWith(updatedAt: now);
        expect(updatedOrder.updatedAt, equals(now));
      });
    });

    group('Shipping Address', () {
      test('order has shipping address', () {
        expect(testOrder.shippingAddress, isNotEmpty);
      });

      test('shipping address can be updated', () {
        const newAddress = '999 New St, Chicago, IL 60601';
        final updatedOrder = testOrder.copyWith(shippingAddress: newAddress);
        expect(updatedOrder.shippingAddress, equals(newAddress));
      });
    });
  });
}
