class AppConfig {
  // Default to the remote backend IP and port provided by the user.
  // Default to localhost for local Docker testing.
  // Previous: static const String apiBaseUrl = 'http://10.10.20.100:8000';
  static const String apiBaseUrl = 'http://localhost:8000';
}
