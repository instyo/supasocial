import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();

  User? get currentUser;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<AuthResponse> signInWithGoogle();

  Future<void> signOut();
}
