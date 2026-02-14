import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/cart.dart';
import '../../services/cart_service.dart';
import '../../widgets/custom/index.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);

    return Scaffold(
      appBar: LuxeAppBar(
        title: 'Shopping Cart',
        leading: const Icon(Icons.arrow_back),
        showDivider: true,
      ),
      body: cartState.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              'Your cart is empty',
              style: AppTheme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacing3),
            Text(
              'Add items to get started',
              style: AppTheme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spacing6),
            LuxeButton(
              label: 'Continue Shopping',
              onPressed: () => context.go('/products'),
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      )
          : Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                // Cart Items
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cartState.cart?.items.length ?? 0,
                  itemBuilder: (context, index) {
                    final item = cartState.cart!.items[index];
                    return CartItemTile(
                      cartItem: item,
                      onQuantityChanged: (newQuantity) async {
                        try {
                          await ref
                              .read(cartNotifierProvider.notifier)
                              .updateItemQuantity(
                            itemId: item.id,
                            quantity: newQuantity,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          }
                        }
                      },
                      onRemove: () async {
                        try {
                          await ref
                              .read(cartNotifierProvider.notifier)
                              .removeItem(item.id);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),

                // Summary
                if (cartState.cart != null && cartState.cart!.items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing4,
                      vertical: AppTheme.spacing6,
                    ),
                    child: LuxeCard(
                      padding: const EdgeInsets.all(AppTheme.spacing4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal',
                                style: AppTheme.textTheme.bodyLarge,
                              ),
                              Text(
                                '\$${cartState.total.toStringAsFixed(2)}',
                                style: AppTheme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          Divider(
                            height: AppTheme.spacing6,
                            color: AppTheme.dividerColor,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Shipping',
                                style: AppTheme.textTheme.bodyLarge,
                              ),
                              Text(
                                'FREE',
                                style: AppTheme.textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            height: AppTheme.spacing6,
                            color: AppTheme.dividerColor,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: AppTheme.textTheme.headlineSmall,
                              ),
                              Text(
                                '\$${cartState.total.toStringAsFixed(2)}',
                                style: AppTheme.textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Checkout Button
          if (cartState.cart != null && cartState.cart!.items.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacing4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.borderColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: LuxeButton(
                  label: 'Proceed to Checkout',
                  onPressed: () => context.push('/checkout'),
                  variant: ButtonVariant.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemTile({
    Key? key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing2,
      ),
      child: LuxeCard(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                image: DecorationImage(
                  image: NetworkImage(cartItem.product.image),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
            ),

            const SizedBox(width: AppTheme.spacing4),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: AppTheme.textTheme.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    '\$${cartItem.product.price.toStringAsFixed(2)}',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppTheme.spacing4),

            // Quantity and Remove
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Quantity Controls
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.borderColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: cartItem.quantity > 1
                            ? () =>
                            onQuantityChanged(cartItem.quantity - 1)
                            : null,
                      ),
                      SizedBox(
                        width: 30,
                        child: Center(
                          child: Text(
                            '${cartItem.quantity}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: () =>
                            onQuantityChanged(cartItem.quantity + 1),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Remove Button
                TextButton(
                  onPressed: onRemove,
                  child: const Text(
                    'Remove',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtotal
                Text(
                  '\$${cartItem.subtotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
