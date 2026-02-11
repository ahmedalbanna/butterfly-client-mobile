import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../services/analytics_service.dart';

/// Widget to display recent orders on dashboard
class RecentOrdersWidget extends StatelessWidget {
  final List<RecentOrder> orders;

  const RecentOrdersWidget({
    Key? key,
    required this.orders,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_outlined,
                  size: 48,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'No recent orders',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () => context.push('/orders'),
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _RecentOrderTile(order: order);
            },
          ),
        ],
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final RecentOrder order;

  const _RecentOrderTile({
    Key? key,
    required this.order,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (order.status) {
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
    return ListTile(
      onTap: () => context.push('/orders/${order.id}'),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.receipt,
          color: _getStatusColor(),
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              order.customer.name ?? order.customer.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${order.total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Text(
            '#${order.id.substring(0, 8)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            '•',
            style: TextStyle(color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(width: 8),
          Text(
            '${order.itemCount} item${order.itemCount != 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            '•',
            style: TextStyle(color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              DateFormat('MMM dd, hh:mm a').format(order.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          order.statusDisplay,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _getStatusColor(),
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
