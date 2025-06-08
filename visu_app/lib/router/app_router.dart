import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visu/services/auth_service.dart';
import 'package:visu/views/auth/login_screen.dart';
import 'package:visu/views/auth/register_screen.dart';
import 'package:visu/views/home_screen.dart';

class AppRouter {

  AppRouter({AuthService? authService})
    : _authService = authService ?? AuthService();
  final AuthService _authService;

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(_authService),
    redirect: _handleRedirect,
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/home'),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    ],
  );

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final String currentPath = state.matchedLocation;

    final List<String> authRequiredRoutes = ['/home'];

    final List<String> authForbiddenRoutes = ['/login', '/register'];

    final bool isLoggedIn = _authService.isLoggedInSync();

    if (isLoggedIn && authForbiddenRoutes.contains(currentPath)) {
      return '/home';
    }

    if (!isLoggedIn && authRequiredRoutes.contains(currentPath)) {
      return '/login';
    }

    return null;
  }
}

/// Utility class to notify the router of authentication state changes
class GoRouterRefreshStream extends ChangeNotifier {
  
  GoRouterRefreshStream(this._authService) {
    _authService.authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  final AuthService _authService;
}
