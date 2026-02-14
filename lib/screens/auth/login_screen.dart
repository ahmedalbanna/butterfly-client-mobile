import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom/index.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authStateProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
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
        title: 'Sign In',
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
                'Welcome Back',
                style: AppTheme.textTheme.displaySmall?.copyWith(
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing3),
              Text(
                'Sign in to access your account',
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing7),
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
              const SizedBox(height: AppTheme.spacing7),
              LuxeButton(
                label: authState.isLoading ? 'Signing In...' : 'Sign In',
                isLoading: authState.isLoading,
                onPressed: authState.isLoading ? () {} : _handleLogin,
                variant: ButtonVariant.primary,
              ),
              const SizedBox(height: AppTheme.spacing6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppTheme.textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () => context.push('/signup'),
                    child: Text(
                      'Sign Up',
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
