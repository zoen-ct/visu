import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/visu.dart';

class AppRouter {
  AppRouter({AuthService? authService})
    : _authService = authService ?? AuthService();
  final AuthService _authService;

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(_authService),
    redirect: _handleRedirect,
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/series'),

      ShellRoute(
        builder: (context, state, child) {
          int currentIndex;
          final String location = state.matchedLocation;

          if (location.startsWith('/series')) {
            currentIndex = 0;
          } else if (location.startsWith('/movies')) {
            currentIndex = 1;
          } else if (location.startsWith('/search')) {
            currentIndex = 2;
          } else if (location.startsWith('/profile')) {
            currentIndex = 3;
          } else {
            currentIndex = 0;
          }

          return MainScreen(currentIndex: currentIndex, child: child);
        },
        routes: [
          GoRoute(
            path: '/series',
            builder: (context, state) => const SeriesScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) {
                  final id =
                      int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                  return SerieDetailScreen(serieId: id);
                },
                routes: [
                  GoRoute(
                    path: 'season/:seasonNumber/episode/:episodeNumber',
                    builder: (context, state) {
                      final serieId =
                          int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                      final seasonNumber =
                          int.tryParse(
                            state.pathParameters['seasonNumber'] ?? '',
                          ) ??
                          1;
                      final episodeNumber =
                          int.tryParse(
                            state.pathParameters['episodeNumber'] ?? '',
                          ) ??
                          1;
                      final serieName = state.extra as String? ?? 'Série';

                      return EpisodeDetailScreen(
                        serieId: serieId,
                        seasonNumber: seasonNumber,
                        episodeNumber: episodeNumber,
                        serieName: serieName,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          GoRoute(
            path: '/movies',
            builder: (context, state) => const MoviesScreen(),
          ),

          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),

          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(path: '/home', redirect: (_, __) => '/series'),
    ],
  );

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final String currentPath = state.matchedLocation;

    final List<String> authRequiredRoutes = [
      '/series',
      '/movies',
      '/search',
      '/profile',
    ];

    final List<String> authForbiddenRoutes = ['/login', '/register'];

    final bool isLoggedIn = _authService.isLoggedInSync();

    if (isLoggedIn && authForbiddenRoutes.contains(currentPath)) {
      return '/series';
    }

    if (!isLoggedIn &&
        authRequiredRoutes.any((route) => currentPath.startsWith(route))) {
      return '/login';
    }

    return null;
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(this._authService) {
    _authService.authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  final AuthService _authService;
}
