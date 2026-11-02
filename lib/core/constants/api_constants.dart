class ApiConstants {
  // Base URLs (Use 10.0.2.2 for Android Emulator, 127.0.0.1 for Web/Desktop, or custom IP for physical device)
  static String laravelBaseUrl = 'http://192.168.1.3:8001/api/v1';
  static String fastApiBaseUrl = 'http://192.168.1.3:8000';

  // Laravel Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Master Data & Reports
  static const String categories = '/categories';
  static const String reports = '/reports';

  // FastAPI ML Inference Endpoint
  static const String predict = '/predict';
  static const String health = '/health';

  // Aliases for convenience
  static String get aiBaseUrl => fastApiBaseUrl;
  static const String aiPredict = predict;
  static const String aiHealth = health;

  // Helper method to switch host dynamically if running on local desktop/web
  static void setBaseHosts({required String laravelHost, required String fastApiHost}) {
    laravelBaseUrl = '$laravelHost/api/v1';
    fastApiBaseUrl = fastApiHost;
  }
}
