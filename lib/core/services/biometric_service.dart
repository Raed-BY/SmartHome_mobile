import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Returns true if device has biometrics and user is enrolled.
  Future<bool> canCheckBiometrics() async {
    try {
      final bool can = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return can && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// Attempts biometric authentication. Returns true on success.
  Future<bool> authenticate({String localizedReason = 'Authenticate'}) async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return didAuthenticate;
    } catch (_) {
      return false;
    }
  }
}
