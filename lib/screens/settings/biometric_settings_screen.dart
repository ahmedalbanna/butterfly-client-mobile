import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxefinds_admin/providers/biometric_provider.dart';
import 'package:luxefinds_admin/services/auth_service.dart';

/// Screen for managing biometric authentication settings
class BiometricSettingsScreen extends ConsumerStatefulWidget {
  const BiometricSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BiometricSettingsScreen> createState() => _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends ConsumerState<BiometricSettingsScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEnrolling = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEnableBiometric() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isEnrolling = true);

    try {
      // Verify credentials first
      final authService = ref.read(authServiceProvider);
      await authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Enable biometric
      final success = await ref.read(biometricProvider.notifier).enableBiometric(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric login enabled successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _emailController.clear();
          _passwordController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to enable biometric login'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isEnrolling = false);
      }
    }
  }

  Future<void> _handleDisableBiometric() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Biometric Login?'),
        content: const Text(
          'You will need to enter your email and password to login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(biometricProvider.notifier).disableBiometric();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric login disabled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _testBiometric() async {
    final result = await ref.read(biometricProvider.notifier).authenticate(
      customReason: 'Test biometric authentication',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result ? 'Authentication successful!' : 'Authentication failed',
          ),
          backgroundColor: result ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final biometricState = ref.watch(biometricProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Settings'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Device Support Info
          Card(
            child: ListTile(
              leading: Icon(
                biometricState.isSupported ? Icons.check_circle : Icons.cancel,
                color: biometricState.isSupported ? Colors.green : Colors.red,
              ),
              title: const Text('Device Support'),
              subtitle: Text(
                biometricState.isSupported
                    ? 'Your device supports biometric authentication'
                    : 'Your device does not support biometric authentication',
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Available Biometric Types
          Card(
            child: ListTile(
              leading: const Icon(Icons.fingerprint, color: Colors.blue),
              title: const Text('Biometric Type'),
              subtitle: Text(biometricState.biometricTypeName),
            ),
          ),

          const SizedBox(height: 8),

          // Current Status
          Card(
            child: ListTile(
              leading: Icon(
                biometricState.isEnabled ? Icons.lock_open : Icons.lock,
                color: biometricState.isEnabled ? Colors.green : Colors.grey,
              ),
              title: const Text('Status'),
              subtitle: Text(
                biometricState.isEnabled
                    ? 'Biometric login is enabled for ${biometricState.storedEmail}'
                    : 'Biometric login is disabled',
              ),
              trailing: biometricState.isEnabled
                  ? ElevatedButton(
                      onPressed: _handleDisableBiometric,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Disable'),
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 24),

          // Enable Biometric Section
          if (!biometricState.isEnabled && biometricState.isSupported) ...[
            const Text(
              'Enable Biometric Login',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your credentials to enable biometric authentication',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isEnrolling,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              enabled: !_isEnrolling,
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _isEnrolling ? null : _handleEnableBiometric,
              icon: _isEnrolling
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.fingerprint),
              label: Text(_isEnrolling ? 'Enrolling...' : 'Enable Biometric Login'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
            ),
          ],

          // Test Biometric Button
          if (biometricState.isSupported && biometricState.isAvailable) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _testBiometric,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Test Biometric Authentication'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],

          // Error Display
          if (biometricState.error != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        biometricState.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Info Section
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'About Biometric Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• Your biometric data never leaves your device\n'
                    '• Credentials are encrypted and stored securely\n'
                    '• You can always use your password as fallback\n'
                    '• Disable biometric login anytime from this screen',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
