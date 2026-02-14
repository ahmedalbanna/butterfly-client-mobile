import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

/// Service for handling biometric authentication
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage;
  final Logger _logger = Logger();

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricEmailKey = 'biometric_email';
  static const String _biometricPasswordKey = 'biometric_password';

  BiometricService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      _logger.e('Error checking device support: $e');
      return false;
    }
  }

  /// Check if biometrics are available on this device
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      _logger.e('Error checking biometrics availability: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      _logger.e('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Get human-readable biometric type name
  String getBiometricTypeName(List<BiometricType> types) {
    if (types.isEmpty) return 'None';
    
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (types.contains(BiometricType.strong)) {
      return 'Biometric';
    } else if (types.contains(BiometricType.weak)) {
      return 'Biometric (Weak)';
    }
    
    return 'Biometric';
  }

  /// Authenticate user with biometrics
  /// Returns true if authentication successful
  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to access your admin account',
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        _logger.w('Device does not support biometrics');
        return false;
      }

      final canCheck = await canCheckBiometrics();
      if (!canCheck) {
        _logger.w('Biometrics not available');
        return false;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true, // Don't allow device PIN as fallback
        ),
      );

      if (authenticated) {
        _logger.i('Biometric authentication successful');
      } else {
        _logger.w('Biometric authentication failed');
      }

      return authenticated;
    } on PlatformException catch (e) {
      _logger.e('Platform exception during biometric auth: $e');
      
      if (e.code == auth_error.notAvailable) {
        _logger.w('Biometric not available on this device');
      } else if (e.code == auth_error.notEnrolled) {
        _logger.w('No biometrics enrolled on this device');
      } else if (e.code == auth_error.lockedOut || 
                 e.code == auth_error.permanentlyLockedOut) {
        _logger.e('Biometric authentication locked out');
      }
      
      return false;
    } catch (e) {
      _logger.e('Error during biometric authentication: $e');
      return false;
    }
  }

  /// Check if biometric login is enabled for this user
  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      _logger.e('Error checking biometric enabled status: $e');
      return false;
    }
  }

  /// Enable biometric login and store credentials
  Future<void> enableBiometric({
    required String email,
    required String password,
  }) async {
    try {
      // Store encrypted credentials
      await _secureStorage.write(key: _biometricEmailKey, value: email);
      await _secureStorage.write(key: _biometricPasswordKey, value: password);
      await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
      
      _logger.i('Biometric login enabled for user: $email');
    } catch (e) {
      _logger.e('Error enabling biometric: $e');
      rethrow;
    }
  }

  /// Disable biometric login and clear stored credentials
  Future<void> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _biometricEmailKey);
      await _secureStorage.delete(key: _biometricPasswordKey);
      await _secureStorage.delete(key: _biometricEnabledKey);
      
      _logger.i('Biometric login disabled');
    } catch (e) {
      _logger.e('Error disabling biometric: $e');
      rethrow;
    }
  }

  /// Get stored credentials (only after successful biometric auth)
  Future<Map<String, String>?> getStoredCredentials() async {
    try {
      final email = await _secureStorage.read(key: _biometricEmailKey);
      final password = await _secureStorage.read(key: _biometricPasswordKey);
      
      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
      
      return null;
    } catch (e) {
      _logger.e('Error getting stored credentials: $e');
      return null;
    }
  }

  /// Get stored email (for display purposes)
  Future<String?> getStoredEmail() async {
    try {
      return await _secureStorage.read(key: _biometricEmailKey);
    } catch (e) {
      _logger.e('Error getting stored email: $e');
      return null;
    }
  }

  /// Check if biometric login is available and configured
  Future<bool> isBiometricAvailable() async {
    final isEnabled = await isBiometricEnabled();
    if (!isEnabled) return false;
    
    final isSupported = await isDeviceSupported();
    if (!isSupported) return false;
    
    final canCheck = await canCheckBiometrics();
    return canCheck;
  }

  /// Stop authentication (cancel ongoing authentication)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      _logger.e('Error stopping authentication: $e');
    }
  }
}
