import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/env.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _googleScopes = ['email', 'profile'];

  bool _googleInitialized = false;

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
  Future<AuthResponse> signInWithGoogle() async {
    if (!Env.hasGoogleSignInConfig) {
      throw const AuthFailure(
        'Google Sign-In is not configured. Set GOOGLE_WEB_CLIENT_ID.',
      );
    }

    try {
      await _ensureGoogleInitialized();

      final googleSignIn = GoogleSignIn.instance;
      final googleUser = await googleSignIn.authenticate(
        scopeHint: _googleScopes,
      );

      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(
            _googleScopes,
          ) ??
          await googleUser.authorizationClient.authorizeScopes(_googleScopes);

      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw const AuthFailure('No ID token returned from Google.');
      }

      return await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization.accessToken,
      );
    } on AuthCancelled {
      rethrow;
    } on AuthFailure {
      rethrow;
    } on GoogleSignInException catch (e) {
      final details = e.description ?? '';
      // Google often maps SHA-1 / OAuth misconfig to "canceled" with code 16.
      if (details.contains('Account reauth failed') ||
          details.contains('[16]')) {
        throw const AuthFailure(
          'Google Sign-In config error. Check Android SHA-1 and OAuth client IDs.',
        );
      }
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw const AuthCancelled();
      }
      throw AuthFailure(
        details.isEmpty ? 'Google sign-in failed.' : details,
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
      if (_googleInitialized) {
        try {
          await GoogleSignIn.instance.signOut();
        } catch (_) {}
      }
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;

    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      serverClientId: Env.googleWebClientId,
      clientId: !kIsWeb && Platform.isIOS ? Env.googleIosClientId : null,
    );
    _googleInitialized = true;
  }
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthCancelled implements Exception {
  const AuthCancelled();
}
