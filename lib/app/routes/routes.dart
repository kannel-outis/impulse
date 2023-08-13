import 'package:flutter/material.dart' hide Path;
import 'package:go_router/go_router.dart';
import 'package:impulse/app/routes/dialog_route.dart';
import 'package:impulse/models/models.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/impulse_scaffold.dart';
import 'package:impulse/views/information/set_info_page.dart';
import 'package:impulse/views/scan/scan_page.dart';
import 'package:impulse/views/scan/widget/scan_dialog.dart';
import 'package:impulse/views/settings/settings_screen.dart';
import 'package:impulse/views/files/file_manager.dart';
import 'package:impulse/views/home/home.dart';

class ImpulseRouter {
  static const routes = _Routes();

  static final mainNavKey = GlobalKey<NavigatorState>();
  static final nestedFolderNavKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: Configurations.instance.user == null
        ? routes.setInfo
        : isAndroid
            ? routes.home
            : routes.folder,
    // initialLocation: routes.setInfo,
    navigatorKey: mainNavKey,
    routes: [
      ImpulseRoute(
        parentNavKey: mainNavKey,
        path: routes.setInfo,
        builder: (s) {
          return const ImpulseScaffold(
            showOverlay: false,
            child: SetInfoPage(),
          );
        },
      ),
      ImpulseRoute(
        parentNavKey: mainNavKey,
        path: routes.scanPage,
        builder: (s) {
          return const ImpulseScaffold(
            showOverlay: false,
            child: ScanPage(),
          );
        },
      ),
      ImpulseRoute(
        parentNavKey: mainNavKey,
        path: routes.scanDialog,
        name: "scan_dialog",
        pageBuilder: (context, state) {
          return DialogPage(
            barrierColor: Colors.black.withOpacity(.5),
            builder: (context) {
              return ScanDialog(
              parentLocation: state.queryParameters["parentLocation"],
              ip: state.queryParameters["id"] as String,
              port: state.queryParameters["port"] as int,
            );
            },
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ImpulseScaffold(child: child);
        },
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return Scaffold(
                body: HomePage(
                  navigationShell: navigationShell,
                ),
                resizeToAvoidBottomInset: false,
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
                          // print(Uri.decodeComponent(s.matchedLocation));
                          // print(Uri.parse(s.location));
                          return FileManagerScreen(
                            // files: s.extra != null
                            //     ? s.extra as List<ImpulseFileEntity>
                            //     : null,
                            // path: s.extra != null ? s.extra as String : null,
                            path: Path(location: s.location),
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
  final String setInfo = "/setInfo";
  final String scanPage = "/scanPage";
  final String scanDialog = "/qrDialog";
}

class ImpulseRoute extends GoRoute {
  final GlobalKey<NavigatorState>? parentNavKey;
  ImpulseRoute({
    required String path,
    Widget Function(GoRouterState s)? builder,
    GoRouterPageBuilder? pageBuilder,
    List<RouteBase> routes = const [],
    String? name,
    this.parentNavKey,
  }) : super(
          path: path,
          name: name,
          routes: routes,
          pageBuilder: pageBuilder ??
              (context, state) {
                final pageContent = Scaffold(
                  body: builder!(state),
                  resizeToAvoidBottomInset: false,
                );

                return NoTransitionPage(
                  key: state.pageKey,
                  child: pageContent,

                  // transitionsBuilder:
                  //     (context, animation, secondaryAnimation, child) {
                  //   return FadeTransition(opacity: animation, child: child);
                  // },
                );
              },
        );

  @override
  GlobalKey<NavigatorState>? get parentNavigatorKey => parentNavKey;
}
