class AppEnv {
  static const String environment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'local/default');
  static const String appName =
      String.fromEnvironment('APP_NAME', defaultValue: 'Interna');
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://localhost:8080');
  static const bool debugMode = bool.fromEnvironment('DEBUG_MODE', defaultValue: true);

  static bool get isDev => environment == 'development';
  static bool get isProd => environment == 'production';
}
