import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuration for backend selection and base API URL.
/// Set `usePhpApi` to true to use the local WAMP PHP API (recommended
/// for this repo as it contains the legacy PHP backend).
const bool usePhpApi = true;

String get apiBaseUrl {
  // For web, localhost will refer to your machine. For Android emulator
  // use 10.0.2.2 which maps to host loopback. For a real device, use
  // your PC's LAN IP (e.g., http://192.168.1.10/CareVaxProject/PROJECT/api).
  if (kIsWeb) return 'http://localhost/CareVaxProject/PROJECT/api';
  return 'http://10.0.2.2/CareVaxProject/PROJECT/api';
}

String childrenEndpoint() => '$apiBaseUrl/children.php';
String followupsEndpoint() => '$apiBaseUrl/followups.php';
String householdsEndpoint() => '$apiBaseUrl/households.php';
