import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Stream<User?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((event) => event.session?.user);
  }

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      return await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': name.trim()},
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
