import 'package:flutter_test/flutter_test.dart';
import 'package:luxefinds_client/models/order.dart';

import '../../helpers/test_fixtures.dart';
import '../../mocks/mock_services.dart';

void main() {
  group('OrderService Tests', () {
    late FakeOrderService orderService;

    setUp(() {
      orderService = FakeOrderService();
      orderService.addOrder(testOrder);
      orderService.addOrder(testOrderProcessing);
      orderService.addOrder(testOrderShipped);
    });

    tearDown(() {
      orderService.clear();
    });

    group('Create Order', () {
      test('successfully creates new order', () async {
        final order = await orderService.createOrder(['1', '2'], '123 Main St');
        expect(order, isNotNull);
        expect(order.id, isNotEmpty);
        expect(order.status, equals('confirmed'));
      });

      test('new order has correct shipping address', () async {
        const address = '456 Oak Ave, Los Angeles, CA 90001';
        final order = await orderService.createOrder(['1'], address);
        expect(order.shippingAddress, equals(address));
      });

      test('new order includes provided products', () async {
        final order = await orderService.createOrder(['1', '2', '3'], '123 Main St');
        expect(order.items, isNotEmpty);
      });

      test('order is saved to order list', () async {
        final initialCount = orderService.orders.length;
        await orderService.createOrder(['1'], '123 Main St');
        expect(orderService.orders.length, equals(initialCount + 1));
      });

      test('throws exception on create failure', () async {
        orderService.exception = Exception('Order creation failed');
        expect(
          () => orderService.createOrder(['1'], '123 Main St'),
          throwsException,
        );
      });

      test('handles multiple products in order', () async {
        final order = await orderService.createOrder(['1', '2', '3', '4'], '123 Main St');
        expect(order, isNotNull);
      });
    });

    group('Get Orders', () {
      test('returns list of orders', () async {
        final orders = await orderService.getOrders();
        expect(orders, isNotEmpty);
        expect(orders.length, equals(3));
      });

      test('returns empty list when no orders exist', () async {
        orderService.clear();
        final orders = await orderService.getOrders();
        expect(orders, isEmpty);
      });

      test('returns orders with correct structure', () async {
        final orders = await orderService.getOrders();
        expect(orders.first.id, isNotEmpty);
        expect(orders.first.status, isNotEmpty);
        expect(orders.first.shippingAddress, isNotEmpty);
      });

      test('throws exception on get failure', () async {
        orderService.exception = Exception('Get orders failed');
        expect(
          () => orderService.getOrders(),
          throwsException,
        );
      });

      test('returns orders in list', () async {
        final orders = await orderService.getOrders();
        expect(orders, isA<List<Order>>());
      });
    });

    group('Get Order By ID', () {
      test('returns order with matching ID', () async {
        final order = await orderService.getOrderById('order-123');
        expect(order.id, equals('order-123'));
      });

      test('throws exception for non-existent order', () async {
        expect(
          () => orderService.getOrderById('non-existent'),
          throwsException,
        );
      });

      test('returns order with all details', () async {
        final order = await orderService.getOrderById('order-123');
        expect(order.userId, isNotEmpty);
        expect(order.items, isNotEmpty);
        expect(order.totalPrice, greaterThan(0));
        expect(order.shippingAddress, isNotEmpty);
      });

      test('throws exception on get failure', () async {
        orderService.exception = Exception('Get order failed');
        expect(
          () => orderService.getOrderById('order-123'),
          throwsException,
        );
      });
    });

    group('Cancel Order', () {
      test('successfully cancels order', () async {
        await orderService.cancelOrder('order-123');
        final order = await orderService.getOrderById('order-123');
        expect(order.status, equals('cancelled'));
      });

      test('preserves order details after cancellation', () async {
        final originalOrder = await orderService.getOrderById('order-123');
        await orderService.cancelOrder('order-123');
        final cancelledOrder = await orderService.getOrderById('order-123');
        
        expect(cancelledOrder.id, equals(originalOrder.id));
        expect(cancelledOrder.userId, equals(originalOrder.userId));
        expect(cancelledOrder.shippingAddress, equals(originalOrder.shippingAddress));
      });

      test('throws exception on cancel failure', () async {
        orderService.exception = Exception('Cancel failed');
        expect(
          () => orderService.cancelOrder('order-123'),
          throwsException,
        );
      });

      test('handles cancelling non-existent order gracefully', () async {
        expect(
          () => orderService.cancelOrder('non-existent'),
          returnsNormally,
        );
      });

      test('can only cancel once', () async {
        await orderService.cancelOrder('order-123');
        await orderService.cancelOrder('order-123');
        final order = await orderService.getOrderById('order-123');
        expect(order.status, equals('cancelled'));
      });
    });

    group('Order Status', () {
      test('new order has confirmed status', () async {
        final order = await orderService.createOrder(['1'], '123 Main St');
        expect(order.status, equals('confirmed'));
      });

      test('processing order has correct status', () async {
        final order = await orderService.getOrderById('order-124');
        expect(order.status, equals('processing'));
      });

      test('shipped order has correct status', () async {
        final order = await orderService.getOrderById('order-125');
        expect(order.status, equals('shipped'));
      });

      test('cancelled order has correct status', () async {
        await orderService.cancelOrder('order-123');
        final order = await orderService.getOrderById('order-123');
        expect(order.status, equals('cancelled'));
      });
    });

    group('Order Details', () {
      test('order has user ID', () async {
        final order = await orderService.getOrderById('order-123');
        expect(order.userId, isNotEmpty);
      });

      test('order has items', () async {
        final order = await orderService.getOrderById('order-123');
        expect(order.items, isNotEmpty);
      });

      test('order has total price', () async {
        final order = await orderService.getOrderById('order-123');
        expect(order.totalPrice, greaterThan(0));
      });

      test('order has shipping address', () async {
        final order = await orderService.getOrderById('order-123');
        expect(order.shippingAddress, isNotEmpty);
      });

      test('order has creation timestamp', () async {
        final order = await orderService.getOrderById('order-123');
        expect(order.createdAt, isNotNull);
      });

      test('order has update timestamp', () async {
        final order = await orderService.getOrderById('order-123');
        expect(order.updatedAt, isNotNull);
      });
    });

    group('Order History', () {
      test('returns all orders for user', () async {
        final orders = await orderService.getOrders();
        expect(orders.length, greaterThanOrEqualTo(3));
      });

      test('can retrieve multiple orders', () async {
        final orders = await orderService.getOrders();
        for (final order in orders) {
          expect(order.id, isNotEmpty);
        }
      });

      test('orders maintain historical data', () async {
        final orders = await orderService.getOrders();
        final oldestOrder = orders.reduce((a, b) => 
          a.createdAt.isBefore(b.createdAt) ? a : b
        );
        expect(oldestOrder.createdAt, isNotNull);
      });
    });
  });
}
