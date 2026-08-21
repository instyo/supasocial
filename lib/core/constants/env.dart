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

  static bool get hasValidCredentials =>
      !supabaseUrl.contains('YOUR_PROJECT') &&
      !supabaseAnonKey.contains('YOUR_SUPABASE');
}
