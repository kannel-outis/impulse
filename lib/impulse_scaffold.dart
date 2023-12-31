import 'package:flutter/material.dart';
// import 'package:impulse/app/utils/alert.dart';

import 'app/app.dart';

class ImpulseScaffold extends StatelessWidget {
  final Widget? child;
  final bool showOverlay;
  final Widget? Function(BuildContext, Widget?)? builder;
  const ImpulseScaffold({
    super.key,
    this.child,
    this.showOverlay = true,
    this.builder,
  });

  static AppStyle get style => _style;
  static AppStyle _style = AppStyle();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _style = AppStyle(screenSize: size);
    return AlertOverlay(
      showOverlay: showOverlay,
      child: KeyedSubtree(
        key: ValueKey($styles.scale),
        child: DefaultTextStyle(
          style: $styles.text.body,
          child: builder?.call(context, child) ?? child!,
        ),
      ),
    );
  }
}
