import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom/index.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: LuxeAppBar(
        title: 'My Profile',
        leading: const Icon(Icons.arrow_back),
        showDivider: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            LuxeCard(
              padding: const EdgeInsets.all(AppTheme.spacing6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceColor,
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        (authState.user?.name?.isNotEmpty ?? false)
                            ? authState.user!.name![0].toUpperCase()
                            : '?',
                        style: AppTheme.textTheme.displayMedium?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    authState.user?.name ?? 'User',
                    style: AppTheme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    authState.user?.email ?? '',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (authState.user?.isAdmin ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: AppTheme.spacing3),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing3,
                          vertical: AppTheme.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(
                            color: AppTheme.primaryColor,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          'Administrator',
                          style: AppTheme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing6),

            // Account Info
            Text(
              'Account Information',
              style: AppTheme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacing3),
            LuxeCard(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: 'Email',
                    value: authState.user?.email ?? 'N/A',
                  ),
                  Divider(
                    height: AppTheme.spacing6,
                    color: AppTheme.dividerColor,
                  ),
                  _InfoRow(
                    label: 'Name',
                    value: authState.user?.name ?? 'N/A',
                  ),
                  Divider(
                    height: AppTheme.spacing6,
                    color: AppTheme.dividerColor,
                  ),
                  _InfoRow(
                    label: 'Account Type',
                    value: authState.user?.isAdmin ?? false
                        ? 'Administrator'
                        : 'Customer',
                  ),
                  Divider(
                    height: AppTheme.spacing6,
                    color: AppTheme.dividerColor,
                  ),
                  _InfoRow(
                    label: 'Member Since',
                    value: authState.user?.createdAt?.year.toString() ??
                        'N/A',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing6),

            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTheme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacing3),
            LuxeButton(
              label: 'View Orders',
              icon: Icons.receipt_outlined,
              variant: ButtonVariant.outline,
              onPressed: () => context.push('/orders'),
            ),
            const SizedBox(height: AppTheme.spacing3),
            LuxeButton(
              label: 'Continue Shopping',
              icon: Icons.shopping_bag_outlined,
              variant: ButtonVariant.outline,
              onPressed: () => context.go('/products'),
            ),

            const SizedBox(height: AppTheme.spacing6),

            // Logout Button
            LuxeButton(
              label: 'Logout',
              icon: Icons.logout,
              variant: ButtonVariant.secondary,
              onPressed: () async {
                try {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
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
            ),

            const SizedBox(height: AppTheme.spacing6),
          ],
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
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        Text(
          value,
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }
}
