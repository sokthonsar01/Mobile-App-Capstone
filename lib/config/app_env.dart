class AppEnv {
  static const String environment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'local/default');
  static const String appName =
      String.fromEnvironment('APP_NAME', defaultValue: 'Interna');

  // NestJS Backend URL
  // Use http://10.0.2.2:3000 for Android Emulator, http://localhost:3000 for iOS simulator
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://fujimqtgrthnslpwjkqf.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_hKZYcT_YUUzY8FRA4jJ4bQ_zt2MPwB6',
  );

  static const bool debugMode =
      bool.fromEnvironment('DEBUG_MODE', defaultValue: true);

  static bool get isDev => environment == 'development';
  static bool get isProd => environment == 'production';
}
