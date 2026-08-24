class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_PROJECT.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  /// Web OAuth client ID — used as serverClientId for native Google Sign-In.
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  /// iOS OAuth client ID (not the reversed URL scheme).
  static const googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue:
        '1026094281591-1ii2lv3bn17s7imc65qbmqsa1f97l51t.apps.googleusercontent.com',
  );

  static bool get hasValidCredentials =>
      !supabaseUrl.contains('YOUR_PROJECT') &&
      !supabaseAnonKey.contains('YOUR_SUPABASE');

  static bool get hasGoogleSignInConfig => googleWebClientId.isNotEmpty;
}
