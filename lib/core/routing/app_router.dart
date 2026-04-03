import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/main/presentation/main_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/activity/presentation/activity_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/devices/presentation/my_devices_screen.dart';
import '../../features/auth/domain/auth_controller.dart';
import 'router_listenable.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final goRouterProvider = Provider<GoRouter>((ref) {
  final listenable = RouterListenable(
    changes: ref.watch(authControllerProvider.notifier).stream,
  );

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/devices',
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isLoggingInOrRegistering = state.uri.path == '/login' || state.uri.path == '/register';

      if (authState.isLoading) {
        return null; // wait
      }

      if (!authState.isAuthenticated && !isLoggingInOrRegistering) {
        return '/login';
      }

      if (authState.isAuthenticated && isLoggingInOrRegistering) {
        return '/devices';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return MainScreen(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/devices',
            builder: (BuildContext context, GoRouterState state) => const MyDevicesScreen(),
          ),
          GoRoute(
            path: '/home/:hardwareId',
            builder: (BuildContext context, GoRouterState state) => DashboardScreen(
              hardwareId: state.pathParameters['hardwareId']!,
            ),
          ),
          GoRoute(
            path: '/activity',
            builder: (BuildContext context, GoRouterState state) => const ActivityScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
