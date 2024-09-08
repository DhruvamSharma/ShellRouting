import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shell_routing/core/shell_builder.dart';
import 'package:shell_routing/main.dart';
import 'package:shell_routing/ui/routes.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AppRouteInformation<T> {
  final T? data;
  final bool maintainState;

  AppRouteInformation({
    this.data,
    this.maintainState = true,
  });
}

class AppRouter {
  // create a singleton
  static final AppRouter instance = AppRouter._internal();

  AppRouter._internal();

  // create a GoRouter instance
  GoRouter? _router;

  GoRouter getRouter(BuildContext context) {
    if (_router == null) {
      _initRouter(context);
      return _router!;
    }
    return _router!;
  }

  void go<T>(String path, {bool maintainState = true, T? data}) {
    _router?.go(
      path,
      extra: AppRouteInformation<T>(
        maintainState: maintainState,
        data: data,
      ),
    );
  }

  Future<T?>? push<T>(String path, {T? data}) {
    return _router?.push<T>(
      path,
      extra: AppRouteInformation<T>(
        maintainState: false,
        data: data,
      ),
    );
  }

  void _initRouter(BuildContext context) {
    _router = GoRouter(
      initialLocation: '/login',
      debugLogDiagnostics: true,
      refreshListenable: isLoggedIn,
      navigatorKey: navigatorKey,
      // redirect: (context, state) {
      //   final isUserLoggedIn = isLoggedIn.value;
      //   final isLoggingIn = state.matchedLocation == '/login';
      //
      //   if (!isUserLoggedIn) return isLoggingIn ? null : '/login';
      //   if (isLoggingIn) return '/';
      //
      //   return null;
      // },
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => MyHomePage(
            navigationShell: navigationShell,
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  redirect: (context, state) => '/uniKonnect',
                ),
                GoRoute(
                  path: '/uniKonnect',
                  builder: (context, state) => DemoPage(
                    title: 'UniKonnect',
                    child: ElevatedButton(
                      onPressed: () {
                        AppRouter.instance.push(
                          '/settings',
                        );
                      },
                      child: const Text('Push Settings'),
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: 'user/:id',
                      builder: (context, state) => UserProfilePage(
                        id: state.pathParameters['id']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/uniGen',
                  builder: (context, state) => const DemoPage(title: 'UniGen'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/uniProfile',
                  // builder: (context, state) => DemoPage(
                  //   /// how to refresh a branch, by changing the key
                  //   /// now every time the branch is navigated to, it will be rebuilt
                  //   /// with a [context.go] call
                  //   ///
                  //   /// We can pass a key to the branch to force it to rebuild
                  //   /// from the state variable
                  //   key: UniqueKey(),
                  //   title: 'UniProfile',
                  // ),
                  pageBuilder: (context, state) {
                    final extra = state.extra as AppRouteInformation<void>?;
                    return buildPage(
                      DemoPage(
                        title: 'UniProfile',
                        child: ElevatedButton(
                          onPressed: () {
                            AppRouter.instance.go('/uniGen');
                          },
                          child: const Text('Go UniGen'),
                        ),
                      ),
                      maintainState: extra?.maintainState ?? true,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => buildPage(const LoginPage()),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => DemoPage(
            title: 'Settings',
            child: ElevatedButton(
              onPressed: () {
                AppRouter.instance.go('/uniProfile');
              },
              child: const Text('Go Login'),
            ),
          ),
        ),

        /// This page if accessed from a deep link will redirect to the user page
        /// but since we want the home page to be the Navigator's stack first entry
        ///
        /// This kind of approach is useful when your design is a little more complex
        ///
        /// Because of the redirect, if a route is accessed from a deep link, it will be the first entry
        /// in the Navigator's stack and if the user presses the back button, they will
        /// be taken to the previous page when context.go was called
        ///
        /// Normally,
        GoRoute(
          path: '/user/:id',
          redirect: (context, state) =>
              '/uniKonnect/user/${state.pathParameters['id']}',
        ),
      ],
    );
  }

  Page buildPage(Widget child, {bool maintainState = true}) {
    return MaterialPage(
      /// how to refresh a branch, by changing the key
      /// now every time the branch is navigated to, it will be rebuilt
      /// with a [context.go] call
      ///
      /// We can pass a key to the branch to force it to rebuild
      /// from the state variable
      key: maintainState ? null : UniqueKey(),
      child: child,
    );
  }
}
