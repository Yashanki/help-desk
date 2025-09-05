import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'features/auth/auth_controller.dart';
import 'features/auth/sign_in_page.dart';
import 'features/customer/customer_dashboard_page.dart';
import 'features/employee/employee_dashboard_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to our AppUser stream (auth + role)
  final appUserAV = ref.watch(appUserStreamProvider);

  return GoRouter(
    initialLocation: '/login',
    // refresh router when auth state changes
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const SignInPage()),
      GoRoute(
        path: '/customer/dashboard',
        builder: (_, __) => const CustomerDashboardPage(),
      ),
      GoRoute(
        path: '/employee/dashboard',
        builder: (_, __) => const EmployeeDashboardPage(),
      ),
    ],
    redirect: (context, state) {
      // While loading user/role, don’t redirect.
      if (appUserAV.isLoading) return null;

      final appUser = appUserAV.valueOrNull;
      final loc = state.matchedLocation; // replaces subloc
      final onLogin = loc == '/login';

      // Not signed in -> must be on /login
      if (appUser == null) {
        return onLogin ? null : '/login';
      }

      // Signed in: send to role home from /login
      if (onLogin) {
        return appUser.role == 'employee'
            ? '/employee/dashboard'
            : '/customer/dashboard';
      }

      // Guard cross-area navigation
      if (loc.startsWith('/employee') && appUser.role != 'employee') {
        return '/customer/dashboard';
      }
      if (loc.startsWith('/customer') && appUser.role != 'customer') {
        return '/employee/dashboard';
      }
      return null;
    },
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
