import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: Impulse(),
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
    );
  }
}
