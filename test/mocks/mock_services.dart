/// Mock implementations of services for testing
library mock_services;

import 'package:luxefinds_client/models/cart.dart';
import 'package:luxefinds_client/models/order.dart';
import 'package:luxefinds_client/models/product.dart';
import 'package:luxefinds_client/models/user.dart';
import 'package:luxefinds_client/services/auth_service.dart';
import 'package:luxefinds_client/services/cart_service.dart';
import 'package:luxefinds_client/services/http_client.dart';
import 'package:luxefinds_client/services/order_service.dart';
import 'package:luxefinds_client/services/product_service.dart';
import 'package:mockito/mockito.dart';

// ============================================================================
// GENERATED MOCKS
// ============================================================================

class MockHttpClient extends Mock implements HttpClient {}

class MockAuthService extends Mock implements AuthService {}

class MockProductService extends Mock implements ProductService {}

class MockCartService extends Mock implements CartService {}

class MockOrderService extends Mock implements OrderService {}

// ============================================================================
// FAKE IMPLEMENTATIONS
// ============================================================================

/// Fake implementation of HttpClient for testing
class FakeHttpClient implements HttpClient {
  final Map<String, dynamic> Function(String url)? responseBuilder;
  final Exception? exception;
  int requestCount = 0;

  FakeHttpClient({this.responseBuilder, this.exception});

  @override
  Future<Map<String, dynamic>> get(String url, {Map<String, String>? headers}) async {
    requestCount++;
    if (exception != null) throw exception!;
    return responseBuilder?.call(url) ?? {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    requestCount++;
    if (exception != null) throw exception!;
    return responseBuilder?.call(url) ?? {};
  }

  @override
  Future<Map<String, dynamic>> put(
    String url, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    requestCount++;
    if (exception != null) throw exception!;
    return responseBuilder?.call(url) ?? {};
  }

  @override
  Future<Map<String, dynamic>> delete(String url, {Map<String, String>? headers}) async {
    requestCount++;
    if (exception != null) throw exception!;
    return responseBuilder?.call(url) ?? {};
  }

  @override
  Future<void> refreshToken() async {
    requestCount++;
    if (exception != null) throw exception!;
  }

  @override
  void setAuthorizationHeader(String token) {}

  @override
  void clearAuthorizationHeader() {}
}

/// Fake implementation of AuthService for testing
class FakeAuthService implements AuthService {
  User? currentUser;
  bool loginSuccess = true;
  bool signupSuccess = true;
  Exception? exception;

  @override
  Future<User> login(String email, String password) async {
    if (exception != null) throw exception!;
    if (!loginSuccess) throw Exception('Login failed');
    currentUser = User(
      id: '123',
      email: email,
      name: 'Test User',
      isAdmin: false,
      createdAt: DateTime.now(),
    );
    return currentUser!;
  }

  @override
  Future<User> signup(String email, String name, String password) async {
    if (exception != null) throw exception!;
    if (!signupSuccess) throw Exception('Signup failed');
    currentUser = User(
      id: '123',
      email: email,
      name: name,
      isAdmin: false,
      createdAt: DateTime.now(),
    );
    return currentUser!;
  }

  @override
  Future<void> logout() async {
    if (exception != null) throw exception!;
    currentUser = null;
  }

  @override
  Future<bool> refreshToken() async {
    if (exception != null) throw exception!;
    return true;
  }

  @override
  User? getCurrentUser() => currentUser;

  @override
  Future<void> resetPassword(String email) async {
    if (exception != null) throw exception!;
  }

  @override
  Future<User> verifyResetToken(String token) async {
    if (exception != null) throw exception!;
    return User(
      id: '123',
      email: 'test@example.com',
      name: 'Test User',
      isAdmin: false,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> updatePassword(String token, String newPassword) async {
    if (exception != null) throw exception!;
  }
}

/// Fake implementation of ProductService for testing
class FakeProductService implements ProductService {
  List<Product> products = [];
  Exception? exception;

  @override
  Future<List<Product>> getProducts({int page = 1, int limit = 6}) async {
    if (exception != null) throw exception!;
    return products;
  }

  @override
  Future<Product> getProductById(String id) async {
    if (exception != null) throw exception!;
    return products.firstWhere((p) => p.id == id);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    if (exception != null) throw exception!;
    return products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    if (exception != null) throw exception!;
    return products.where((p) => p.category == category).toList();
  }

  void addProduct(Product product) => products.add(product);
  void clear() => products.clear();
}

/// Fake implementation of CartService for testing
class FakeCartService implements CartService {
  Cart? cart;
  Exception? exception;

  @override
  Future<Cart> getCart() async {
    if (exception != null) throw exception!;
    return cart ??
        Cart(
          id: 'cart-123',
          userId: '123',
          items: [],
          totalPrice: 0,
          totalItems: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
  }

  @override
  Future<Cart> addToCart(String productId, int quantity) async {
    if (exception != null) throw exception!;
    // Simple implementation for testing
    final newItem = CartItem(
      productId: productId,
      name: 'Product $productId',
      price: 100.0,
      quantity: quantity,
      imageUrl: 'https://example.com/image.jpg',
    );
    cart ??= Cart(
      id: 'cart-123',
      userId: '123',
      items: [],
      totalPrice: 0,
      totalItems: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    cart!.items.add(newItem);
    cart = cart!.copyWith(
      items: [...cart!.items],
      totalItems: cart!.totalItems + quantity,
      totalPrice: cart!.totalPrice + (100.0 * quantity),
    );
    return cart!;
  }

  @override
  Future<Cart> removeFromCart(String productId) async {
    if (exception != null) throw exception!;
    cart = cart?.copyWith(
      items: cart!.items.where((item) => item.productId != productId).toList(),
    );
    return cart!;
  }

  @override
  Future<Cart> updateCartItem(String productId, int quantity) async {
    if (exception != null) throw exception!;
    // Implementation for testing
    return cart ?? Cart(
      id: 'cart-123',
      userId: '123',
      items: [],
      totalPrice: 0,
      totalItems: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> clearCart() async {
    if (exception != null) throw exception!;
    cart = null;
  }
}

/// Fake implementation of OrderService for testing
class FakeOrderService implements OrderService {
  List<Order> orders = [];
  Exception? exception;

  @override
  Future<Order> createOrder(List<String> productIds, String shippingAddress) async {
    if (exception != null) throw exception!;
    final newOrder = Order(
      id: 'order-${DateTime.now().millisecondsSinceEpoch}',
      userId: '123',
      items: [],
      totalPrice: 0,
      status: 'confirmed',
      shippingAddress: shippingAddress,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    orders.add(newOrder);
    return newOrder;
  }

  @override
  Future<List<Order>> getOrders() async {
    if (exception != null) throw exception!;
    return orders;
  }

  @override
  Future<Order> getOrderById(String id) async {
    if (exception != null) throw exception!;
    return orders.firstWhere((o) => o.id == id);
  }

  @override
  Future<void> cancelOrder(String id) async {
    if (exception != null) throw exception!;
    final index = orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      orders[index] = orders[index].copyWith(status: 'cancelled');
    }
  }

  void addOrder(Order order) => orders.add(order);
  void clear() => orders.clear();
}
