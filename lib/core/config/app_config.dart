class AppConfig {
  // Main backend endpoint used by all HTTP calls.
  // Update this URL when running backend on another machine.
  static const String baseUrl = 'http://localhost:3000/smarthome';
  // Example LAN endpoint if backend is on another device.
  // const String baseUrl = "http://172.20.10.2:3000/smarthome";

  static const String familyUUID = "01234567-89ab-cdef-0123-456789abcdef";
}
