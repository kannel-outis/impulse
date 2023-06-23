import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';

class BottomAppBarIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  const BottomAppBarIcon({
    super.key,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: $styles.insets.xs.insets,
      child: Icon(
        icon,
        size: 25.scale,
        color: color,
      ),
    );
  }
}
