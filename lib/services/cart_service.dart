import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/cart.dart';
import '../models/product.dart';
import 'http_client.dart';
import 'auth_service.dart';

final cartServiceProvider = Provider((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return CartService(httpClient);
});

class CartService {
  final HttpClient _httpClient;
  final Logger _logger = Logger();

  CartService(this._httpClient);

  /// Get current user's cart
  Future<Cart> getCart() async {
    try {
      _logger.i('Fetching cart');

      final response = await _httpClient.get<Map<String, dynamic>>(
        '/cart',
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          return Cart.fromJson(data['data']);
        }
      }

      throw CartException(
        response.data?['error'] ?? 'Failed to fetch cart',
      );
    } catch (e) {
      _logger.e('Get cart error: $e');
      if (e is CartException) {
        rethrow;
      }
      throw CartException(e.toString());
    }
  }

  /// Add item to cart
  Future<CartItem> addItem({
    required String productId,
    required int quantity,
  }) async {
    try {
      _logger.i('Adding item to cart - ProductId: $productId, Qty: $quantity');

      final response = await _httpClient.post<Map<String, dynamic>>(
        '/cart/items',
        data: {
          'productId': productId,
          'quantity': quantity,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data!;
        if (data['success'] == true) {
          return CartItem.fromJson(data['data']);
        }
      }

      throw CartException(
        response.data?['error'] ?? 'Failed to add item to cart',
      );
    } catch (e) {
      _logger.e('Add item error: $e');
      if (e is CartException) {
        rethrow;
      }
      throw CartException(e.toString());
    }
  }

  /// Update cart item quantity
  Future<CartItem> updateItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      _logger.i('Updating cart item - ItemId: $itemId, NewQty: $quantity');

      final response = await _httpClient.put<Map<String, dynamic>>(
        '/cart/items/$itemId',
        data: {
          'quantity': quantity,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          return CartItem.fromJson(data['data']);
        }
      }

      throw CartException(
        response.data?['error'] ?? 'Failed to update cart item',
      );
    } catch (e) {
      _logger.e('Update item error: $e');
      if (e is CartException) {
        rethrow;
      }
      throw CartException(e.toString());
    }
  }

  /// Remove item from cart
  Future<void> removeItem(String itemId) async {
    try {
      _logger.i('Removing item from cart - ItemId: $itemId');

      final response = await _httpClient.delete<Map<String, dynamic>>(
        '/cart/items/$itemId',
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['success'] == true) {
          _logger.i('Item removed from cart');
          return;
        }
      }

      throw CartException(
        response.data?['error'] ?? 'Failed to remove item from cart',
      );
    } catch (e) {
      _logger.e('Remove item error: $e');
      if (e is CartException) {
        rethrow;
      }
      throw CartException(e.toString());
    }
  }
}

class CartException implements Exception {
  final String message;

  CartException(this.message);

  @override
  String toString() => message;
}

/// Cart state provider
final cartProvider = FutureProvider<Cart>((ref) async {
  final service = ref.watch(cartServiceProvider);
  return service.getCart();
});

/// Notifier for cart operations
final cartNotifierProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) {
    final service = ref.watch(cartServiceProvider);
    return CartNotifier(service);
  },
);

class CartState {
  final Cart? cart;
  final bool isLoading;
  final String? error;

  CartState({
    this.cart,
    this.isLoading = false,
    this.error,
  });

  bool get isEmpty => cart?.items.isEmpty ?? true;
  int get itemCount => cart?.itemCount ?? 0;
  double get total => cart?.total ?? 0.0;

  CartState copyWith({
    Cart? cart,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  CartState clearError() {
    return CartState(cart: cart, isLoading: isLoading);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final CartService _cartService;

  CartNotifier(this._cartService) : super(CartState(isLoading: true)) {
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    try {
      final cart = await _cartService.getCart();
      state = CartState(cart: cart);
    } catch (e) {
      state = CartState(cart: Cart(userId: '', items: []), error: e.toString());
    }
  }

  Future<void> addItem({
    required String productId,
    required Product product,
    int quantity = 1,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _cartService.addItem(
        productId: productId,
        quantity: quantity,
      );
      // Refresh cart
      await _initializeCart();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _cartService.updateItem(
        itemId: itemId,
        quantity: quantity,
      );
      // Refresh cart
      await _initializeCart();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> removeItem(String itemId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _cartService.removeItem(itemId);
      // Refresh cart
      await _initializeCart();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void clearError() {
    state = state.clearError();
  }
}
