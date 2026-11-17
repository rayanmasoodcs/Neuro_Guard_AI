/// Stub implementation for non-web platforms. Keeps the same function signature
/// so the service can call it unconditionally.
Future<Map<String, String>?> requestDeviceViaBrowser() async {
  return null;
}

Future<bool> connectToDevice(String id) async {
  return false;
}

Future<void> disconnectDevice(String id) async {}


