import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/impulse_scaffold.dart';
import 'package:impulse/views/shared/custom_speed_dial.dart';
import 'package:impulse/views/files/file_manager.dart';
import 'package:impulse/views/home/home.dart';
import 'package:impulse_utils/impulse_utils.dart';

class ImpulseRouter {
  static const routes = _Routes();

  static final router = GoRouter(
    initialLocation: routes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return ImpulseScaffold(child: child);
        },
        routes: [
          // ImpulseRoute(routes.test, (_) => const TestPage()),

          ImpulseRoute(routes.home, (_) => const HomePage()),

          ///TODO: will remove later
          ImpulseRoute(
            routes.folder,
            (s) => FileManagerScreen(
              files:
                  s.extra != null ? s.extra as List<ImpulseFileEntity> : null,
            ),
          ),
        ],
      ),
    ],
  );
}

class _Routes {
  const _Routes();

  final String home = "/home";
  final String test = "/test";

  ////
  final String folder = "/folder";
}

class ImpulseRoute extends GoRoute {
  ImpulseRoute(String path, Widget Function(GoRouterState s) builder,
      {List<GoRoute> routes = const []})
      : super(
          path: path,
          routes: routes,
          pageBuilder: (context, state) {
            final pageContent = Scaffold(
              body: builder(state),
              resizeToAvoidBottomInset: false,
            );

            return CustomTransitionPage(
              key: state.pageKey,
              child: pageContent,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            );
          },
        );
}
