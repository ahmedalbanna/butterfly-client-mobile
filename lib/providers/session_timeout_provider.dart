import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxefinds_admin/services/auth_service.dart';
import 'package:logger/logger.dart';

/// Session timeout configuration
class SessionTimeoutConfig {
  /// Total idle timeout duration (default: 30 minutes)
  final Duration timeout;
  
  /// Warning duration before timeout (default: 2 minutes)
  final Duration warningDuration;
  
  /// Whether session timeout is enabled
  final bool enabled;

  const SessionTimeoutConfig({
    this.timeout = const Duration(minutes: 30),
    this.warningDuration = const Duration(minutes: 2),
    this.enabled = true,
  });

  /// Get remaining time until warning
  Duration get timeUntilWarning => timeout - warningDuration;
}

/// Session timeout state
enum SessionTimeoutState {
  active,      // Session is active
  warning,     // Warning shown, about to timeout
  timedOut,    // Session has timed out
}

/// Session timeout notifier
class SessionTimeoutNotifier extends StateNotifier<SessionTimeoutState> {
  final AuthService _authService;
  final SessionTimeoutConfig _config;
  final Logger _logger = Logger();

  Timer? _timeoutTimer;
  Timer? _warningTimer;
  DateTime _lastActivityTime = DateTime.now();

  SessionTimeoutNotifier(
    this._authService, {
    SessionTimeoutConfig? config,
  })  : _config = config ?? const SessionTimeoutConfig(),
        super(SessionTimeoutState.active) {
    if (_config.enabled) {
      _startTimers();
    }
  }

  /// Record user activity (resets timeout)
  void recordActivity() {
    if (!_config.enabled) return;
    
    _lastActivityTime = DateTime.now();
    
    // Reset to active state if in warning
    if (state == SessionTimeoutState.warning) {
      state = SessionTimeoutState.active;
    }
    
    // Restart timers
    _startTimers();
  }

  /// Start timeout and warning timers
  void _startTimers() {
    // Cancel existing timers
    _cancelTimers();

    // Set warning timer
    _warningTimer = Timer(_config.timeUntilWarning, () {
      if (state != SessionTimeoutState.timedOut) {
        _logger.w('Session timeout warning triggered');
        state = SessionTimeoutState.warning;
      }
    });

    // Set timeout timer
    _timeoutTimer = Timer(_config.timeout, () async {
      if (state != SessionTimeoutState.timedOut) {
        _logger.w('Session timeout triggered - logging out');
        state = SessionTimeoutState.timedOut;
        await _handleTimeout();
      }
    });
  }

  /// Handle session timeout
  Future<void> _handleTimeout() async {
    try {
      // Auto-logout
      await _authService.logout();
      _logger.i('User logged out due to inactivity');
    } catch (e) {
      _logger.e('Error during timeout logout: $e');
    }
  }

  /// Cancel all timers
  void _cancelTimers() {
    _timeoutTimer?.cancel();
    _warningTimer?.cancel();
    _timeoutTimer = null;
    _warningTimer = null;
  }

  /// Get time since last activity
  Duration getTimeSinceLastActivity() {
    return DateTime.now().difference(_lastActivityTime);
  }

  /// Get remaining time until timeout
  Duration getRemainingTime() {
    final elapsed = getTimeSinceLastActivity();
    final remaining = _config.timeout - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Pause session timeout (e.g., when app is in background)
  void pause() {
    _logger.d('Session timeout paused');
    _cancelTimers();
  }

  /// Resume session timeout (e.g., when app returns to foreground)
  void resume() {
    if (!_config.enabled) return;
    
    _logger.d('Session timeout resumed');
    final elapsed = getTimeSinceLastActivity();
    
    if (elapsed >= _config.timeout) {
      // Already timed out
      state = SessionTimeoutState.timedOut;
      _handleTimeout();
    } else if (elapsed >= _config.timeUntilWarning) {
      // In warning period
      state = SessionTimeoutState.warning;
      _startTimers();
    } else {
      // Still active
      _startTimers();
    }
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}

/// Session timeout provider
final sessionTimeoutProvider = StateNotifierProvider<SessionTimeoutNotifier, SessionTimeoutState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return SessionTimeoutNotifier(authService);
});

/// Session timeout config provider (can be overridden for testing)
final sessionTimeoutConfigProvider = Provider<SessionTimeoutConfig>((ref) {
  return const SessionTimeoutConfig(
    timeout: Duration(minutes: 30),
    warningDuration: Duration(minutes: 2),
    enabled: true,
  );
});
