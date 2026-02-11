import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../services/analytics_service.dart';

/// Widget to display low stock products with warning styling
class LowStockWidget extends StatelessWidget {
  final List<LowStockProduct> products;

  const LowStockWidget({
    Key? key,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: AppTheme.successColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'All products well stocked!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.successColor,
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
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Low Stock Alert',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${products.length} item${products.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length > 10 ? 10 : products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = products[index];
              return _LowStockProductTile(product: product);
            },
          ),
          if (products.length > 10)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: TextButton(
                  onPressed: () => context.push('/products'),
                  child: Text('View all ${products.length} low stock products'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LowStockProductTile extends StatelessWidget {
  final LowStockProduct product;

  const _LowStockProductTile({
    Key? key,
    required this.product,
  }) : super(key: key);

  Color _getStockColor() {
    if (product.stock == 0) {
      return AppTheme.errorColor;
    } else if (product.stock < 5) {
      return Colors.red.shade600;
    } else {
      return Colors.orange;
    }
  }

  IconData _getStockIcon() {
    if (product.stock == 0) {
      return Icons.error;
    } else {
      return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/products/${product.id}/edit'),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getStockColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getStockIcon(),
          color: _getStockColor(),
          size: 20,
        ),
      ),
      title: Text(
        product.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(
            product.categoryName,
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
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStockColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${product.stock} left',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _getStockColor(),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Restock: ${product.suggestedRestock}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}
