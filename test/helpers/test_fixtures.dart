/// Test fixtures for common test data across unit and widget tests
library test_fixtures;

import 'package:luxefinds_client/models/cart.dart';
import 'package:luxefinds_client/models/order.dart';
import 'package:luxefinds_client/models/product.dart';
import 'package:luxefinds_client/models/user.dart';

// ============================================================================
// USER FIXTURES
// ============================================================================

final testUser = User(
  id: '123',
  email: 'test@example.com',
  name: 'Test User',
  isAdmin: false,
  createdAt: DateTime(2024, 1, 1),
);

final testAdminUser = User(
  id: '456',
  email: 'admin@example.com',
  name: 'Admin User',
  isAdmin: true,
  createdAt: DateTime(2024, 1, 1),
);

// ============================================================================
// PRODUCT FIXTURES
// ============================================================================

final testProduct1 = Product(
  id: '1',
  name: 'Luxury Watch',
  description: 'Premium Swiss Watch with leather strap',
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

final testProduct2 = Product(
  id: '2',
  name: 'Designer Sunglasses',
  description: 'Authentic designer sunglasses with UV protection',
  price: 850.0,
  category: 'Accessories',
  imageUrl: 'https://example.com/sunglasses.jpg',
  materials: ['Acetate', 'Glass'],
  care: ['Store in protective case'],
  inStock: true,
  stock: 15,
  rating: 4.8,
  reviews: 42,
);

final testProduct3OutOfStock = Product(
  id: '3',
  name: 'Limited Edition Bag',
  description: 'Exclusive designer handbag',
  price: 3200.0,
  category: 'Bags',
  imageUrl: 'https://example.com/bag.jpg',
  materials: ['Leather'],
  care: ['Professional cleaning recommended'],
  inStock: false,
  stock: 0,
  rating: 4.9,
  reviews: 18,
);

final List<Product> testProducts = [testProduct1, testProduct2, testProduct3OutOfStock];

// ============================================================================
// CART FIXTURES
// ============================================================================

final testCartItem1 = CartItem(
  productId: '1',
  name: 'Luxury Watch',
  price: 2500.0,
  quantity: 1,
  imageUrl: 'https://example.com/watch.jpg',
);

final testCartItem2 = CartItem(
  productId: '2',
  name: 'Designer Sunglasses',
  price: 850.0,
  quantity: 2,
  imageUrl: 'https://example.com/sunglasses.jpg',
);

final testCart = Cart(
  id: 'cart-123',
  userId: '123',
  items: [testCartItem1, testCartItem2],
  totalPrice: 2500.0 + (850.0 * 2),
  totalItems: 3,
  createdAt: DateTime(2024, 1, 15),
  updatedAt: DateTime(2024, 1, 15),
);

final testEmptyCart = Cart(
  id: 'cart-123',
  userId: '123',
  items: [],
  totalPrice: 0.0,
  totalItems: 0,
  createdAt: DateTime(2024, 1, 15),
  updatedAt: DateTime(2024, 1, 15),
);

// ============================================================================
// ORDER FIXTURES
// ============================================================================

final testOrderItem1 = OrderItem(
  productId: '1',
  name: 'Luxury Watch',
  price: 2500.0,
  quantity: 1,
  imageUrl: 'https://example.com/watch.jpg',
);

final testOrderItem2 = OrderItem(
  productId: '2',
  name: 'Designer Sunglasses',
  price: 850.0,
  quantity: 2,
  imageUrl: 'https://example.com/sunglasses.jpg',
);

final testOrder = Order(
  id: 'order-123',
  userId: '123',
  items: [testOrderItem1, testOrderItem2],
  totalPrice: 2500.0 + (850.0 * 2),
  status: 'confirmed',
  shippingAddress: '123 Main St, New York, NY 10001',
  createdAt: DateTime(2024, 1, 15),
  updatedAt: DateTime(2024, 1, 15),
);

final testOrderProcessing = Order(
  id: 'order-124',
  userId: '123',
  items: [testOrderItem1],
  totalPrice: 2500.0,
  status: 'processing',
  shippingAddress: '123 Main St, New York, NY 10001',
  createdAt: DateTime(2024, 1, 14),
  updatedAt: DateTime(2024, 1, 14),
);

final testOrderShipped = Order(
  id: 'order-125',
  userId: '123',
  items: [testOrderItem2],
  totalPrice: 1700.0,
  status: 'shipped',
  shippingAddress: '123 Main St, New York, NY 10001',
  createdAt: DateTime(2024, 1, 10),
  updatedAt: DateTime(2024, 1, 12),
);

final List<Order> testOrders = [testOrder, testOrderProcessing, testOrderShipped];

// ============================================================================
// API RESPONSE FIXTURES
// ============================================================================

final Map<String, dynamic> userLoginResponse = {
  'success': true,
  'user': {
    'id': '123',
    'email': 'test@example.com',
    'name': 'Test User',
    'isAdmin': false,
    'createdAt': '2024-01-01T00:00:00.000Z',
  },
  'accessToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.token',
  'refreshToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.refresh.token',
};

final Map<String, dynamic> productsListResponse = {
  'success': true,
  'data': [
    {
      'id': '1',
      'name': 'Luxury Watch',
      'description': 'Premium Swiss Watch with leather strap',
      'price': 2500.0,
      'category': 'Watches',
      'imageUrl': 'https://example.com/watch.jpg',
      'materials': ['Stainless Steel', 'Leather'],
      'care': ['Clean with soft cloth'],
      'inStock': true,
      'stock': 10,
      'rating': 4.5,
      'reviews': 25,
    },
    {
      'id': '2',
      'name': 'Designer Sunglasses',
      'description': 'Authentic designer sunglasses with UV protection',
      'price': 850.0,
      'category': 'Accessories',
      'imageUrl': 'https://example.com/sunglasses.jpg',
      'materials': ['Acetate', 'Glass'],
      'care': ['Store in protective case'],
      'inStock': true,
      'stock': 15,
      'rating': 4.8,
      'reviews': 42,
    },
  ],
  'pagination': {
    'page': 1,
    'limit': 6,
    'total': 2,
  },
};

final Map<String, dynamic> tokenRefreshResponse = {
  'success': true,
  'accessToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.new.token',
  'refreshToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.new.refresh.token',
};

final Map<String, dynamic> createOrderResponse = {
  'success': true,
  'data': {
    'id': 'order-123',
    'userId': '123',
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
    'shippingAddress': '123 Main St, New York, NY 10001',
    'createdAt': '2024-01-15T00:00:00.000Z',
    'updatedAt': '2024-01-15T00:00:00.000Z',
  },
};

final Map<String, dynamic> errorResponse = {
  'success': false,
  'error': 'Internal Server Error',
};

final Map<String, dynamic> unauthorizedResponse = {
  'success': false,
  'error': 'Unauthorized',
};
