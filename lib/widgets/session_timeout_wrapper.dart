import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luxefinds_admin/providers/session_timeout_provider.dart';
import 'package:luxefinds_admin/services/auth_service.dart';

/// Widget that wraps the app and tracks user activity for session timeout
class SessionTimeoutWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const SessionTimeoutWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<SessionTimeoutWrapper> createState() => _SessionTimeoutWrapperState();
}

class _SessionTimeoutWrapperState extends ConsumerState<SessionTimeoutWrapper>
    with WidgetsBindingObserver {
  bool _hasShownWarning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final sessionTimeout = ref.read(sessionTimeoutProvider.notifier);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App returned to foreground
        sessionTimeout.resume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        // App went to background
        sessionTimeout.pause();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _handleUserActivity() {
    // Record activity when user interacts
    ref.read(sessionTimeoutProvider.notifier).recordActivity();
    _hasShownWarning = false; // Reset warning flag
  }

  void _showTimeoutWarning(BuildContext context) {
    if (_hasShownWarning) return;
    _hasShownWarning = true;

    final sessionTimeout = ref.read(sessionTimeoutProvider.notifier);
    final remainingTime = sessionTimeout.getRemainingTime();
    final remainingMinutes = remainingTime.inMinutes;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Session Timeout Warning',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'You will be logged out in $remainingMinutes minutes due to inactivity.',
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Stay Active',
          textColor: Colors.white,
          onPressed: () {
            _handleUserActivity();
          },
        ),
      ),
    );
  }

  void _handleTimeout(BuildContext context) {
    // Show timeout message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.logout, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Session Expired',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('You have been logged out due to inactivity.'),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );

    // Navigate to login
    context.go('/login?timeout=true');
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state to enable/disable timeout
    final authState = ref.watch(authStateProvider);
    final sessionTimeoutState = ref.watch(sessionTimeoutProvider);

    // Only track timeout for authenticated users
    if (authState.isAuthenticated) {
      // Show warning dialog when entering warning state
      if (sessionTimeoutState == SessionTimeoutState.warning && !_hasShownWarning) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showTimeoutWarning(context);
        });
      }

      // Handle timeout
      if (sessionTimeoutState == SessionTimeoutState.timedOut) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleTimeout(context);
        });
      }
    }

    // Wrap with GestureDetector to track user activity
    return Listener(
      onPointerDown: (_) => _handleUserActivity(),
      onPointerMove: (_) => _handleUserActivity(),
      onPointerUp: (_) => _handleUserActivity(),
      child: widget.child,
    );
  }
}

/// Dialog shown when session is about to timeout
class SessionTimeoutDialog extends StatelessWidget {
  final Duration remainingTime;
  final VoidCallback onStayActive;

  const SessionTimeoutDialog({
    Key? key,
    required this.remainingTime,
    required this.onStayActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds % 60;

    return AlertDialog(
      icon: const Icon(Icons.timer_outlined, color: Colors.orange, size: 48),
      title: const Text('Session Timeout Warning'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Your session will expire in $minutes:${seconds.toString().padLeft(2, '0')} due to inactivity.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Click "Stay Active" to continue your session.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Logout Now'),
        ),
        ElevatedButton(
          onPressed: () {
            onStayActive();
            Navigator.of(context).pop();
          },
          child: const Text('Stay Active'),
        ),
      ],
    );
  }
}
