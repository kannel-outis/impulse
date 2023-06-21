import 'package:flutter/material.dart';

import 'app/app.dart';

class ImpulseScaffold extends StatelessWidget {
  final Widget child;
  const ImpulseScaffold({
    super.key,
    required this.child,
  });

  static AppStyle get style => _style;
  static AppStyle _style = AppStyle();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _style = AppStyle(screenSize: size);
    print(_style.sizes);
    return KeyedSubtree(
      key: ValueKey(_style.scale),
      child: Theme(
        data: $styles.colors.theme,
        child: child,
      ),
    );
  }
}
