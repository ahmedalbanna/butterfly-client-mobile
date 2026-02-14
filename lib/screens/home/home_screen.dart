import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import '../../widgets/custom/index.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final productsAsync = ref.watch(
      productsProvider(ProductsParams(limit: 6)),
    );
    final categoriesAsync = ref.watch(categoriesProvider);
    final cartState = ref.watch(cartNotifierProvider);

    Future<void> onRefresh() async {
      // Refresh both products and categories
      await Future.wait([
        ref.refresh(productsProvider(ProductsParams(limit: 6)).future),
        ref.refresh(categoriesProvider.future),
      ]);
    }

    return Scaffold(
      appBar: LuxeAppBar(
        title: 'LuxeFinds',
        centerTitle: true,
        actions: [
          AppBarAction(
            icon: Icons.shopping_bag_outlined,
            badge: cartState.itemCount > 0 ? '${cartState.itemCount}' : null,
            onPressed: () => context.push('/cart'),
          ),
          const SizedBox(width: AppTheme.spacing2),
          AppBarAction(
            icon: Icons.person_outline,
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.surfaceColor.withOpacity(0.8),
                    AppTheme.backgroundColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.borderColor,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${authState.user?.name ?? 'Guest'}',
                    style: AppTheme.textTheme.displaySmall?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing3),
                  Text(
                    'Discover exquisite luxury accessories curated just for you',
                    style: AppTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondaryColor,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing6),
                  LuxeButton(
                    label: 'Explore Collection',
                    icon: Icons.shopping_bag_outlined,
                    variant: ButtonVariant.primary,
                    onPressed: () => context.push('/products'),
                  ),
                ],
              ),
            ),

            // Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing6,
                vertical: AppTheme.spacing6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shop by Category',
                    style: AppTheme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  categoriesAsync.when(
                    data: (categories) {
                      return SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => const SizedBox(
                            width: AppTheme.spacing3,
                          ),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return GestureDetector(
                              onTap: () => context.push(
                                '/products?categoryId=${category.id}',
                              ),
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 100),
                                padding: const EdgeInsets.all(AppTheme.spacing4),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusLarge,
                                  ),
                                  border: Border.all(
                                    color: AppTheme.borderColor,
                                    width: 1,
                                  ),
                                  boxShadow: AppTheme.shadowSmall,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.category_outlined,
                                      color: AppTheme.primaryColor,
                                      size: 28,
                                    ),
                                    const SizedBox(height: AppTheme.spacing2),
                                    Text(
                                      category.name,
                                      style: AppTheme.textTheme.labelLarge,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    error: (error, stack) => Text(
                      'Error loading categories',
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Featured Products Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing6,
                vertical: AppTheme.spacing6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Collection',
                        style: AppTheme.textTheme.headlineSmall,
                      ),
                      TextButton(
                        onPressed: () => context.push('/products'),
                        child: Text(
                          'View All',
                          style: AppTheme.textTheme.labelLarge?.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  productsAsync.when(
                    data: (response) {
                      final products = response.data;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: AppTheme.spacing4,
                          mainAxisSpacing: AppTheme.spacing4,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(
                            imageUrl: product.image,
                            title: product.name,
                            price: product.price,
                            category: product.category?.name,
                            onTap: () => context.push(
                              '/products/${product.id}',
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const SizedBox(
                      height: 400,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    error: (error, stack) => Text(
                      'Error loading products',
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing6),
          ],
        ),
        ),
      ),
    );
  }
}
