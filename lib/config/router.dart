import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/products/product_form_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_detail_screen.dart' show OrderDetailScreenWidget;
import '../screens/categories/categories_screen.dart';
import '../screens/users/users_screen.dart';
import '../screens/users/user_detail_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: authState.isLoading ? '/' : (authState.user != null ? '/dashboard' : '/login'),
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final hasUser = authState.user != null;
      final isGoingToLogin = state.matchedLocation == '/login';

      if (isLoading) return null;

      if (!hasUser) {
        if (isGoingToLogin) return null;
        return '/login';
      }

      // Verify admin access
      if (!(authState.user?.isAdmin ?? false)) {
        return '/login';
      }

      if (isGoingToLogin) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: '/products/new',
        name: 'product_new',
        builder: (context, state) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '/products/:id/edit',
        name: 'product_edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductFormScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        name: 'order_detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderDetailScreenWidget(orderId: id);
        },
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/users',
        name: 'users',
        builder: (context, state) => const UsersScreen(),
      ),
      GoRoute(
        path: '/users/:id',
        name: 'user_detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return UserDetailScreen(userId: id);
        },
      ),
    ],
  );
});
