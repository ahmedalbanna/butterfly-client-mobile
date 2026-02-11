import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:luxefinds_admin/services/biometric_service.dart';
import 'package:logger/logger.dart';

/// Biometric authentication state
class BiometricState {
  final bool isSupported;
  final bool isEnabled;
  final bool isAvailable;
  final List<BiometricType> availableTypes;
  final String? storedEmail;
  final bool isLoading;
  final String? error;

  const BiometricState({
    this.isSupported = false,
    this.isEnabled = false,
    this.isAvailable = false,
    this.availableTypes = const [],
    this.storedEmail,
    this.isLoading = false,
    this.error,
  });

  BiometricState copyWith({
    bool? isSupported,
    bool? isEnabled,
    bool? isAvailable,
    List<BiometricType>? availableTypes,
    String? storedEmail,
    bool? isLoading,
    String? error,
  }) {
    return BiometricState(
      isSupported: isSupported ?? this.isSupported,
      isEnabled: isEnabled ?? this.isEnabled,
      isAvailable: isAvailable ?? this.isAvailable,
      availableTypes: availableTypes ?? this.availableTypes,
      storedEmail: storedEmail ?? this.storedEmail,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  String get biometricTypeName {
    if (availableTypes.isEmpty) return 'None';
    
    if (availableTypes.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (availableTypes.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    }
    return 'Biometric';
  }

  bool get canUseBiometric => isSupported && isAvailable && isEnabled;
}

/// Biometric state notifier
class BiometricNotifier extends StateNotifier<BiometricState> {
  final BiometricService _biometricService;
  final Logger _logger = Logger();

  BiometricNotifier(this._biometricService) : super(const BiometricState()) {
    _initialize();
  }

  /// Initialize biometric state
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      final isSupported = await _biometricService.isDeviceSupported();
      final canCheck = await _biometricService.canCheckBiometrics();
      final availableTypes = await _biometricService.getAvailableBiometrics();
      final isEnabled = await _biometricService.isBiometricEnabled();
      final storedEmail = await _biometricService.getStoredEmail();

      state = BiometricState(
        isSupported: isSupported,
        isEnabled: isEnabled,
        isAvailable: canCheck,
        availableTypes: availableTypes,
        storedEmail: storedEmail,
        isLoading: false,
      );

      _logger.i('Biometric initialized: supported=$isSupported, enabled=$isEnabled');
    } catch (e) {
      _logger.e('Error initializing biometric: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticate({
    String? customReason,
  }) async {
    try {
      final reason = customReason ?? 
          'Authenticate to access LuxeFinds Admin';

      final result = await _biometricService.authenticate(
        localizedReason: reason,
        useErrorDialogs: true,
        stickyAuth: false,
      );

      return result;
    } catch (e) {
      _logger.e('Error during biometric authentication: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Enable biometric login
  Future<bool> enableBiometric({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // First, authenticate with biometrics to ensure it works
      final authenticated = await authenticate(
        customReason: 'Authenticate to enable biometric login',
      );

      if (!authenticated) {
        state = state.copyWith(
          isLoading: false,
          error: 'Biometric authentication failed',
        );
        return false;
      }

      // Store credentials
      await _biometricService.enableBiometric(
        email: email,
        password: password,
      );

      state = state.copyWith(
        isEnabled: true,
        storedEmail: email,
        isLoading: false,
      );

      _logger.i('Biometric login enabled successfully');
      return true;
    } catch (e) {
      _logger.e('Error enabling biometric: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Disable biometric login
  Future<void> disableBiometric() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _biometricService.disableBiometric();

      state = state.copyWith(
        isEnabled: false,
        storedEmail: null,
        isLoading: false,
      );

      _logger.i('Biometric login disabled successfully');
    } catch (e) {
      _logger.e('Error disabling biometric: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Get stored credentials after successful biometric auth
  Future<Map<String, String>?> getStoredCredentials() async {
    try {
      return await _biometricService.getStoredCredentials();
    } catch (e) {
      _logger.e('Error getting stored credentials: $e');
      return null;
    }
  }

  /// Refresh biometric availability
  Future<void> refresh() async {
    await _initialize();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Biometric service provider
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// Biometric state provider
final biometricProvider = StateNotifierProvider<BiometricNotifier, BiometricState>((ref) {
  final service = ref.watch(biometricServiceProvider);
  return BiometricNotifier(service);
});
