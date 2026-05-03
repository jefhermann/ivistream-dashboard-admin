import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth.dart';
import '../features/dashboard/dashboard.dart';
import '../features/users/users.dart';
import '../features/producers/producers.dart';

part 'app_router.gr.dart';

// ============================================================
// Auth Guard
// ============================================================

class AuthGuard extends AutoRouteGuard {
  final Ref _ref;

  AuthGuard(this._ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final authState = _ref.read(authControllerProvider);

    if (authState.isAuthenticated) {
      resolver.next(true);
    } else {
      resolver.redirectUntil(const AuthRoute());
    }
  }
}

// ============================================================
// Router
// ============================================================

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final Ref _ref;

  AppRouter(this._ref);

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/login',
          page: AuthRoute.page,
        ),
        AutoRoute(
          path: '/',
          page: DashboardShellRoute.page,
          guards: [AuthGuard(_ref)],
          children: [
            AutoRoute(path: 'dashboard', page: DashboardRoute.page, initial: true),
            AutoRoute(path: 'users', page: UsersRoute.page),
            AutoRoute(path: 'contents', page: ContentsRoute.page),
            AutoRoute(path: 'producers', page: ProducersRoute.page),
            AutoRoute(path: 'team', page: AdminTeamRoute.page),
          ],
        ),
      ];

  @override
  List<AutoRouteGuard> get guards => [];
}

// ============================================================
// Provider
// ============================================================

final appRouterProvider = Provider<AppRouter>((ref) {
  return AppRouter(ref);
});
