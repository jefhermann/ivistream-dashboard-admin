import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth.dart';
import '../features/content_gender/content_gender.dart';
import '../features/country/country.dart';
import '../features/dashboard/dashboard.dart';
import '../features/person/person.dart';
import '../features/users/users.dart';
import '../features/producers/producers.dart';
import '../features/contents/contents.dart';
import '../features/revenues/revenues.dart';
import '../features/team/team.dart';

part 'app_router.gr.dart';

// ============================================================
// Auth Guard
// ============================================================

class AuthGuard extends AutoRouteGuard {
  final Ref _ref;

  AuthGuard(this._ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
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
            // AutoRoute(path: 'contents', page: ContentsRoute.page),
            AutoRoute(
              path: 'contents',
              page: ContentsWrapperRoute.page, // Le wrapper que tu viens de créer
              children: [
                AutoRoute(path: '', page: ContentsRoute.page), // Liste par défaut[cite: 24]
                AutoRoute(path: ':contentId', page: ContentDetailRoute.page),
                AutoRoute(path: 'add', page: AddContentRoute.page),
                AutoRoute(path: 'edit', page: EditContentRoute.page),
              ],
            ),
            AutoRoute(path: 'producers', page: ProducersRoute.page),
            AutoRoute(path: 'revenues', page: RevenuesRoute.page),
            AutoRoute(path: 'team', page: AdminTeamRoute.page),
            AutoRoute(path: 'genres', page: ContentGenderRoute.page),
            AutoRoute(path: 'persons', page: PersonRoute.page),
            AutoRoute(path: 'countries', page: CountryRoute.page),
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
