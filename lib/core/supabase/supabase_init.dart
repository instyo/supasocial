import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/env.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );
}

SupabaseClient get supabaseClient => Supabase.instance.client;
