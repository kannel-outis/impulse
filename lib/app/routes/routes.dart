import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/impulse_scaffold.dart';
import 'package:impulse/views/settings/settings_screen.dart';
import 'package:impulse/views/files/file_manager.dart';
import 'package:impulse/views/home/home.dart';

class ImpulseRouter {
  static const routes = _Routes();

  static final mainNavKey = GlobalKey<NavigatorState>();
  static final nestedFolderNavKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: isAndroid ? routes.home : routes.folder,
    navigatorKey: mainNavKey,
    routes: [
      // ShellRoute(
      //   navigatorKey: mainNavKey,
      //   builder: (context, state, child) {
      //     return ImpulseScaffold(child: child);
      //   },
      //   routes: [
      //     // ImpulseRoute(routes.test, (_) => const TestPage()),

      //     ImpulseRoute(routes.home, (_) => const HomePage()),

      //     ///TODO: will remove later
      //     ShellRoute(
      //       navigatorKey: nestedFolderNavKey,
      //       builder: (context, state, child) {
      //         return ImpulseScaffold(child: child);
      //       },
      //       routes: [
      //         ImpulseRoute(
      //           "${routes.folder}/:folder",
      //           (s) {
      //             return FileManagerScreen(
      //               files: s.extra != null
      //                   ? s.extra as List<ImpulseFileEntity>
      //                   : null,
      //             );
      //           },
      //           parentNavKey: nestedFolderNavKey,
      //         ),
      //       ],
      //     ),
      //     ImpulseRoute(
      //       routes.transfer,
      //       (s) => const TransferPage(),
      //     )
      //   ],
      // ),

      ShellRoute(
        builder: (context, state, child) {
          return ImpulseScaffold(child: child);
        },
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return HomePage(
                navigationShell: navigationShell,
              );
            },
            branches: [
              if (isAndroid)
                StatefulShellBranch(
                  routes: [
                    ImpulseRoute(
                      path: routes.home,
                      builder: (s) {
                        return const Home();
                      },
                    ),
                  ],
                ),
              StatefulShellBranch(
                navigatorKey: nestedFolderNavKey,
                routes: [
                  ImpulseRoute(
                    path: routes.folder,
                    builder: (s) {
                      return const FileManagerScreen();
                    },
                    routes: [
                      ImpulseRoute(
                        path: "files/:path",
                        name: "filesPath",
                        builder: (s) {
                          print(Uri.decodeComponent(s.matchedLocation));
                          // print(Uri.parse(s.location));
                          return FileManagerScreen(
                            // files: s.extra != null
                            //     ? s.extra as List<ImpulseFileEntity>
                            //     : null,
                            // path: s.extra != null ? s.extra as String : null,
                            path: s.pathParameters["path"] as String,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  ImpulseRoute(
                    path: routes.settings,
                    builder: (s) => const SettingScreen(),
                  )
                ],
              ),
            ],
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
  final String transfer = "/transfer";

  ////
  final String folder = "/folder";
  final String settings = "/settings";
}

class ImpulseRoute extends GoRoute {
  final GlobalKey<NavigatorState>? parentNavKey;
  ImpulseRoute(
      {required String path,
      required Widget Function(GoRouterState s) builder,
      List<RouteBase> routes = const [],
      String? name,
      this.parentNavKey})
      : super(
          path: path,
          name: name,
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

  @override
  GlobalKey<NavigatorState>? get parentNavigatorKey => parentNavKey;
}
