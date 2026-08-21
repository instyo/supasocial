import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_init.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(supabaseClient);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.signUp(
        email: email,
        password: password,
        name: name,
      );
    });
    return !state.hasError;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.signIn(
        email: email,
        password: password,
      );
    });
    return !state.hasError;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.signOut());
  }

  void reset() {
    state = const AsyncData(null);
  }
}
