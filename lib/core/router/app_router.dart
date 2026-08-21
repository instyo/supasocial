import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/home/presentation/screens/home_placeholder_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  final refresh = GoRouterRefreshStream(authRepository.authStateChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/sign-in',
    refreshListenable: refresh,
    redirect: (context, state) {
      final isLoggedIn = authRepository.currentUser != null;
      final location = state.matchedLocation;
      final isAuthRoute =
          location == '/sign-in' || location == '/sign-up';

      if (!isLoggedIn && !isAuthRoute) {
        return '/sign-in';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePlaceholderScreen(),
      ),
    ],
  );
});
