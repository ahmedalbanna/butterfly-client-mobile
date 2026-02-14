import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/analytics_service.dart';
import 'widgets/stat_card.dart';
import 'widgets/recent_orders_widget.dart';
import 'widgets/low_stock_widget.dart';
import 'widgets/revenue_chart.dart';
import 'widgets/orders_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    // Only fetch analytics when user is authenticated
    final analyticsAsync = authState.isAuthenticated 
        ? ref.watch(analyticsProvider)
        : const AsyncValue.loading();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(analyticsProvider);
            },
            tooltip: 'Refresh analytics',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(analyticsProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${authState.user?.name ?? 'Admin'}',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your LuxeFinds store',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 32),
              
              // Analytics Section
              analyticsAsync.when(
                data: (analytics) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    
                    // Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        StatCardWithBreakdown(
                          title: 'Total Orders',
                          value: '${analytics.orders.total}',
                          icon: Icons.receipt_outlined,
                          color: Colors.blue,
                          breakdown: {
                            'Pending': analytics.orders.pending,
                            'Processing': analytics.orders.processing,
                            'Shipped': analytics.orders.shipped,
                            'Delivered': analytics.orders.delivered,
                            'Cancelled': analytics.orders.cancelled,
                          },
                          onTap: () => context.push('/orders'),
                        ),
                        StatCard(
                          title: 'Total Revenue',
                          value: '\$${analytics.revenue.total.toStringAsFixed(2)}',
                          icon: Icons.attach_money,
                          color: AppTheme.successColor,
                          subtitle: 'This month: \$${analytics.revenue.thisMonth.toStringAsFixed(2)}',
                        ),
                        StatCard(
                          title: 'Low Stock',
                          value: '${analytics.products.lowStock}',
                          icon: Icons.warning_amber_rounded,
                          color: analytics.products.lowStock > 0 
                              ? Colors.orange 
                              : AppTheme.successColor,
                          subtitle: '${analytics.products.outOfStock} out of stock',
                        ),
                        StatCard(
                          title: 'Products',
                          value: '${analytics.products.total}',
                          icon: Icons.shopping_bag_outlined,
                          color: AppTheme.primaryColor,
                          subtitle: '${analytics.products.total - analytics.products.outOfStock} in stock',
                          onTap: () => context.push('/products'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Charts Section
                    Text(
                      'Analytics',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    
                    // Revenue & Orders Charts
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 900) {
                          // Two columns on wider screens
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: RevenueChart(revenue: analytics.revenue),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OrdersChart(orders: analytics.orders),
                              ),
                            ],
                          );
                        } else {
                          // Single column on narrow screens
                          return Column(
                            children: [
                              RevenueChart(revenue: analytics.revenue),
                              const SizedBox(height: 16),
                              OrdersChart(orders: analytics.orders),
                            ],
                          );
                        }
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Recent Orders
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    RecentOrdersWidget(orders: analytics.recentOrders),
                    
                    const SizedBox(height: 24),
                    
                    // Low Stock Products
                    if (analytics.lowStockProducts.isNotEmpty) ...[
                      LowStockWidget(products: analytics.lowStockProducts),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load analytics',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.invalidate(analyticsProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  DashboardCard(
                    title: 'Products',
                    icon: Icons.shopping_bag_outlined,
                    description: 'Manage products',
                    onTap: () => context.push('/products'),
                  ),
                  DashboardCard(
                    title: 'Orders',
                    icon: Icons.receipt_outlined,
                    description: 'View all orders',
                    onTap: () => context.push('/orders'),
                  ),
                  DashboardCard(
                    title: 'Categories',
                    icon: Icons.category_outlined,
                    description: 'Manage categories',
                    onTap: () => context.push('/categories'),
                  ),
                  DashboardCard(
                    title: 'Users',
                    icon: Icons.people_outlined,
                    description: 'Manage users',
                    onTap: () => context.push('/users'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final VoidCallback onTap;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.description,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
