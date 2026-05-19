import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AppConfig {
  // Primary LAN target for physical devices
  static const String smartHomeHost = '172.20.10.4';
  static const String baseUrlHost = 'http://$smartHomeHost:3000/smarthome';
  static const String webBaseUrl = baseUrlHost;
  static const String mobileBaseUrl = baseUrlHost;

  static String _activeMobileBaseUrl = mobileBaseUrl;

  static List<String> get mobileBaseUrlCandidates => [
        _activeMobileBaseUrl,
        mobileBaseUrl,
        'http://172.20.10.2:3000/smarthome',
        'http://10.0.2.2:3000/smarthome',
        'http://$smartHomeHost:3000/smarthome',
      ];

  static String get baseUrl => kIsWeb ? webBaseUrl : _activeMobileBaseUrl;

  static void setMobileBaseUrl(String value) {
    _activeMobileBaseUrl = value;
  }

  // Verify backend is reachable and switch to a healthy candidate if needed
  static Future<bool> ensureReachable({Duration? timeout}) async {
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
