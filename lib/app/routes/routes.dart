import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/impulse_scaffold.dart';
import 'package:impulse/test.dart';
import 'package:impulse/views/settings/settings_screen.dart';
import 'package:impulse/views/shared/custom_speed_dial.dart';
import 'package:impulse/views/files/file_manager.dart';
import 'package:impulse/views/home/home.dart';
import 'package:impulse/views/transfer/transfer_page.dart';
import 'package:impulse_utils/impulse_utils.dart';

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

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ImpulseScaffold(
            child: HomePage(
              navigationShell: navigationShell,
            ),
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
                    // name: "insideFolder",
                    builder: (s) {
                      print(s.fullPath);
                      return FileManagerScreen(
                        // files: s.extra != null
                        //     ? s.extra as List<ImpulseFileEntity>
                        //     : null,
                        path: s.extra != null ? s.extra as String : null,
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
      List<GoRoute> routes = const [],
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
