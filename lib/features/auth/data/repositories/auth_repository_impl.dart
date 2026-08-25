import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/env.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _googleScopes = ['email', 'profile'];
  static const _oauthTimeout = Duration(minutes: 3);

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
      throw AuthFailure(details.isEmpty ? 'Google sign-in failed.' : details);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  @override
  Future<AuthResponse> signInWithApple() async {
    // Apple platforms: native Sign in with Apple → ID token.
    // Android / web / desktop: browser OAuth + deep link (Supabase docs).
    final useNativeApple = !kIsWeb && (Platform.isIOS || Platform.isMacOS);
    if (useNativeApple) {
      return _signInWithAppleNative();
    }
    return _signInWithAppleOAuth();
  }

  /// Native Apple sheet → Supabase `signInWithIdToken` (iOS / macOS).
  Future<AuthResponse> _signInWithAppleNative() async {
    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw const AuthFailure(
          'Sign in with Apple is not available on this device.',
        );
      }

      final rawNonce = _client.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthFailure('No ID token returned from Apple.');
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      await _syncAppleFullName(credential);
      return response;
    } on AuthCancelled {
      rethrow;
    } on AuthFailure {
      rethrow;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthCancelled();
      }
      throw AuthFailure(e.message);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  /// Browser OAuth → deep link session (Android / non-Apple platforms).
  ///
  /// Per Supabase docs: do **not** use `sign_in_with_apple` here.
  /// Use `signInWithOAuth` + deep link. Requires [Env.authRedirectUrl] in
  /// Supabase Auth → URL configuration → Redirect URLs.
  Future<AuthResponse> _signInWithAppleOAuth() async {
    try {
      // Listen before launching so we never miss the signedIn event.
      final signedIn = _client.auth.onAuthStateChange
          .firstWhere(
            (data) =>
                data.event == AuthChangeEvent.signedIn && data.session != null,
          )
          .timeout(_oauthTimeout);

      final launched = await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: kIsWeb ? null : Env.authRedirectUrl,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );

      if (!launched) {
        throw const AuthFailure('Could not open Apple sign-in.');
      }

      final data = await signedIn;
      final session = data.session;
      if (session == null) {
        throw const AuthFailure('Apple sign-in failed. Please try again.');
      }

      return AuthResponse(session: session, user: session.user);
    } on AuthCancelled {
      rethrow;
    } on AuthFailure {
      rethrow;
    } on TimeoutException {
      // User closed the browser or never completed OAuth.
      if (_client.auth.currentSession != null) {
        final session = _client.auth.currentSession!;
        return AuthResponse(session: session, user: session.user);
      }
      throw const AuthCancelled();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      if (e is AuthFailure || e is AuthCancelled) rethrow;
      throw AuthFailure(
        e is Exception
            ? e.toString().replaceFirst('Exception: ', '')
            : 'Something went wrong. Please try again.',
      );
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

  /// Apple only returns the user's name on the first authorization.
  Future<void> _syncAppleFullName(
    AuthorizationCredentialAppleID credential,
  ) async {
    final parts = [
      credential.givenName,
      credential.familyName,
    ].whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty);

    final fullName = parts.join(' ');
    if (fullName.isEmpty) return;

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client.auth.updateUser(
        UserAttributes(data: {'full_name': fullName}),
      );
      await _client
          .from('profiles')
          .update({'full_name': fullName})
          .eq('id', userId);
    } catch (_) {
      // Non-fatal: session is already established.
    }
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
