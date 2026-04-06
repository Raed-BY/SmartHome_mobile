class AppConfig {
  // Main backend endpoint used by all HTTP calls.
  // For USB debugging on a physical Android device, use localhost with adb reverse.
  static const String baseUrl = 'http://127.0.0.1:3000/smarthome';

  static const String familyUUID = "01234567-89ab-cdef-0123-456789abcdef";
}
