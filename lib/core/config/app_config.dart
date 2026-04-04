class AppConfig {
  // Main backend endpoint used by all HTTP calls.
  // Use the PC LAN IP so both the emulator and the physical phone can reach it.
  static const String baseUrl = 'http://192.168.100.56:3000/smarthome';

  static const String familyUUID = "01234567-89ab-cdef-0123-456789abcdef";
}
