import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/custom/index.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  late OrdersParams _params;

  @override
  void initState() {
    super.initState();
    _params = OrdersParams();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider(_params));

    return Scaffold(
      appBar: LuxeAppBar(
        title: 'My Orders',
        leading: const Icon(Icons.arrow_back),
        showDivider: true,
      ),
      body: ordersAsync.when(
        data: (response) {
          if (response.data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_outlined,
                    size: 64,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    'No orders yet',
                    style: AppTheme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTheme.spacing3),
                  Text(
                    'Start shopping to create your first order',
                    style: AppTheme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppTheme.spacing6),
                  LuxeButton(
                    label: 'Start Shopping',
                    onPressed: () => context.go('/products'),
                    variant: ButtonVariant.primary,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            itemCount: response.data.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacing3),
            itemBuilder: (context, index) {
              final order = response.data[index];
              return OrderCard(order: order);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor,
            ),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
               'Error loading orders',
               style: AppTheme.textTheme.bodySmall?.copyWith(
                 color: AppTheme.errorColor,
               ),
             ),
              const SizedBox(height: AppTheme.spacing6),
              LuxeButton(
                label: 'Retry',
                onPressed: () {
                  setState(() {});
                },
                variant: ButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({
    Key? key,
    required this.order,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}'),
      child: LuxeCard(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: AppTheme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppTheme.spacing1),
                    Text(
                      DateFormat('MMM dd, yyyy').format(order.createdAt!),
                      style: AppTheme.textTheme.bodySmall,
                      ),
                    ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing3,
                    vertical: AppTheme.spacing1,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(
                      color: _getStatusColor(order.status),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    order.statusDisplay,
                    style: AppTheme.textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing3),
            Divider(
              color: AppTheme.dividerColor,
              height: AppTheme.spacing4,
            ),
            const SizedBox(height: AppTheme.spacing3),
            Text(
              '${order.items.length} item(s)',
              style: AppTheme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacing3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppTheme.textTheme.bodyMedium,
                ),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
