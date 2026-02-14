import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../widgets/custom/index.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  String _paymentMethod = 'credit_card';
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      final customerAddress =
          '${_addressController.text}, ${_cityController.text}, ${_stateController.text} ${_zipController.text}';

      try {
        await ref.read(checkoutNotifierProvider.notifier).checkout(
          customerAddress: customerAddress,
          paymentMethod: _paymentMethod,
        );

        if (mounted) {
          final checkoutState = ref.read(checkoutNotifierProvider);
          if (checkoutState.order != null) {
            context.go('/orders/${checkoutState.order!.id}');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final checkoutState = ref.watch(checkoutNotifierProvider);

    return Scaffold(
      appBar: LuxeAppBar(
        title: 'Checkout',
        leading: const Icon(Icons.arrow_back),
        showDivider: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Order Summary
              LuxeCard(
                padding: const EdgeInsets.all(AppTheme.spacing4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: AppTheme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    if (cartState.cart != null) ...[
                      ...cartState.cart!.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.product.name} x${item.quantity}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                ),
                                Text(
                                  '\$${item.subtotal.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${cartState.total.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ]
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacing6),

              // Shipping Address
              Text(
                'Shipping Address',
                style: AppTheme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacing4),
              LuxeInput(
                label: 'Street Address',
                hint: '123 Main Street',
                controller: _addressController,
                prefixIcon: Icons.location_on_outlined,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Street address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing4),
              Row(
                children: [
                  Expanded(
                    child: LuxeInput(
                      label: 'City',
                      hint: 'City',
                      controller: _cityController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'City is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing4),
                  Expanded(
                    child: LuxeInput(
                      label: 'State',
                      hint: 'State',
                      controller: _stateController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'State is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing4),
              LuxeInput(
                label: 'ZIP Code',
                hint: '12345',
                controller: _zipController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'ZIP code is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppTheme.spacing6),

              // Payment Method
              Text(
                'Payment Method',
                style: AppTheme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacing4),
              LuxeCard(
                padding: const EdgeInsets.all(AppTheme.spacing4),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Text(
                        'Credit Card',
                        style: AppTheme.textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        'Visa, Mastercard, American Express',
                        style: AppTheme.textTheme.bodySmall,
                      ),
                      value: 'credit_card',
                      groupValue: _paymentMethod,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Text(
                        'Debit Card',
                        style: AppTheme.textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        'Debit card payments',
                        style: AppTheme.textTheme.bodySmall,
                      ),
                      value: 'debit_card',
                      groupValue: _paymentMethod,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Text(
                        'PayPal',
                        style: AppTheme.textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        'PayPal account',
                        style: AppTheme.textTheme.bodySmall,
                      ),
                      value: 'paypal',
                      groupValue: _paymentMethod,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacing6),

              // Terms and Conditions
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'I agree to the terms and conditions',
                      style: AppTheme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacing6),

              // Place Order Button
              LuxeButton(
                label: checkoutState.isLoading ? 'Processing...' : 'Place Order',
                isLoading: checkoutState.isLoading,
                onPressed: checkoutState.isLoading ? () {} : _handleCheckout,
                variant: ButtonVariant.primary,
              ),

              if (checkoutState.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppTheme.spacing4),
                  child: Text(
                    checkoutState.error!,
                    style: AppTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.errorColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: AppTheme.spacing6),
            ],
          ),
        ],
    );
  }
}
