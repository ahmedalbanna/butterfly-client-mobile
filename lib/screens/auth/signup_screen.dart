import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom/index.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authStateProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );

        if (mounted) {
          context.go('/home');
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: LuxeAppBar(
        title: 'Sign Up',
        leading: const Icon(Icons.arrow_back),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing6),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTheme.spacing7),
              Text(
                'Join LuxeFinds',
                style: AppTheme.textTheme.displaySmall?.copyWith(
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing3),
              Text(
                'Create your account to explore luxury',
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing7),
              LuxeInput(
                label: 'Full Name',
                hint: 'John Doe',
                controller: _nameController,
                prefixIcon: Icons.person_outlined,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Name is required';
                  }
                  if (value!.length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing6),
              LuxeInput(
                label: 'Email Address',
                hint: 'your@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing6),
              LuxeInput(
                label: 'Password',
                hint: '••••••••',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                suffixIcon: Icons.visibility,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Password is required';
                  }
                  if (value!.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing6),
              LuxeInput(
                label: 'Confirm Password',
                hint: '••••••••',
                controller: _confirmPasswordController,
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                suffixIcon: Icons.visibility,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing7),
              LuxeButton(
                label: authState.isLoading ? 'Creating Account...' : 'Create Account',
                isLoading: authState.isLoading,
                onPressed: authState.isLoading ? () {} : _handleSignup,
                variant: ButtonVariant.primary,
              ),
              const SizedBox(height: AppTheme.spacing6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTheme.textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      'Sign In',
                      style: AppTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
