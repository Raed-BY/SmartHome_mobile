import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'smarthome_token';
  static const _keyEmail = 'smarthome_email';
  static const _keyPass = 'smarthome_pass';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  static Future<String?> readToken() async {
    return await _storage.read(key: _keyToken);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
  }

  // Credentials storage (encrypted). Used when user requests biometric unlock
  // to retrieve email/password locally. Passwords are stored on-device only.
  static Future<void> saveCredentials(String email, String pass) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPass, value: pass);
  }

  static Future<Map<String, String?>> readCredentials() async {
    final email = await _storage.read(key: _keyEmail);
    final pass = await _storage.read(key: _keyPass);
    return {'email': email, 'pass': pass};
  }

  static Future<void> clearCredentials() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPass);
  }
}
