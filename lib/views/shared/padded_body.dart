import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';

class PaddedBody extends StatelessWidget {
  final Widget child;
  const PaddedBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ($styles.insets.md, 0.0).insets,
      child: child,
    );
  }
}
