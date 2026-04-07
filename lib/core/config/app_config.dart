import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AppConfig {
  // Web runs in browser on your PC, so localhost works there.
  static const String webBaseUrl = 'http://127.0.0.1:3000/smarthome';
  // Phones must use your PC LAN IP on the same Wi-Fi network.
  static const String mobileBaseUrl = 'http://192.168.100.56:3000/smarthome';
  static const String emulatorBaseUrl = 'http://10.0.2.2:3000/smarthome';
  static const String reverseTunnelBaseUrl = 'http://127.0.0.1:3000/smarthome';
  static const String fallbackLanBaseUrl = 'http://192.168.1.7:3000/smarthome';

  static String _activeMobileBaseUrl = mobileBaseUrl;

  static List<String> get mobileBaseUrlCandidates => [
        _activeMobileBaseUrl,
        mobileBaseUrl,
        emulatorBaseUrl,
        reverseTunnelBaseUrl,
        fallbackLanBaseUrl,
      ];

  static String get baseUrl => kIsWeb ? webBaseUrl : _activeMobileBaseUrl;

  static void setMobileBaseUrl(String value) {
    _activeMobileBaseUrl = value;
  }

  static Future<bool> ensureReachable({Duration? timeout}) async {
    if (kIsWeb) {
      return true;
    }

    final requestTimeout = timeout ?? const Duration(seconds: 3);
    final candidates = mobileBaseUrlCandidates.toSet();

    for (final base in candidates) {
      try {
        final res =
            await http.get(Uri.parse('$base/status')).timeout(requestTimeout);
        if (res.statusCode == 200) {
          _activeMobileBaseUrl = base;
          return true;
        }
      } catch (_) {}
    }

    return false;
  }

  static const String familyUUID = "01234567-89ab-cdef-0123-456789abcdef";
}
