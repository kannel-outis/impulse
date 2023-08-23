import 'package:flutter/material.dart';

class ImpulseInkWell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const ImpulseInkWell({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: child,
    );
  }
}
