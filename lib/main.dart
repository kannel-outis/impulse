import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/controllers/controllers.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Configurations.instance.loadAllInit();
  final container = ProviderContainer();
  // container.
  if (isAndroid) {
    container.read(homeProvider).getAllApplications();
    // await FileManager.instance.getRootPaths(true);
  }
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: Impulse(),
    ),
  );
}

class Impulse extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  Impulse({super.key});

  // ignore: library_private_types_in_public_api
  late final _ImpulseState state;

  @override
  // ignore: no_logic_in_create_state
  State<Impulse> createState() => state = _ImpulseState();
}

class _ImpulseState extends State<Impulse> {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _themeMode = Configurations.instance.themeMode ?? _themeMode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationProvider: ImpulseRouter.router.routeInformationProvider,
      routeInformationParser: ImpulseRouter.router.routeInformationParser,
      debugShowCheckedModeBanner: false,
      routerDelegate: ImpulseRouter.router.routerDelegate,
      theme: $styles.colors.themeLight,
      darkTheme: $styles.colors.theme,
      themeMode: _themeMode,
      // builder: (context, child) => child!,
    );
  }

  void toggleThemeMode([ThemeMode? themeMode]) {
    if (themeMode != null) {
      _themeMode = themeMode;
      setState(() {});
      return;
    }
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    setState(() {});
  }
}
