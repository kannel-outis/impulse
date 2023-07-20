import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/configuration.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse_utils/impulse_utils.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Configurations.instance.loadPaths();
  final container = ProviderContainer();
  // container.
  if (isAndroid) {
    container.read(homeProvider).getAllApplications();
    await FileManager.instance.getRootPaths(true);
  }
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const Impulse(),
    ),
  );
}

class Impulse extends StatelessWidget {
  const Impulse({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationProvider: ImpulseRouter.router.routeInformationProvider,
      routeInformationParser: ImpulseRouter.router.routeInformationParser,
      debugShowCheckedModeBanner: false,
      routerDelegate: ImpulseRouter.router.routerDelegate,
      theme: ThemeData(
        fontFamily: $styles.text.body.fontFamily,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      // builder: (context, child) => child!,
    );
  }
}
