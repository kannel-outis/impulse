import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';

class BottomAppBarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const BottomAppBarIcon({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ($styles.insets.sm, 0.0).insets,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 25.scale,
            color: color,
          ),
          Text(
            label,
            style: $styles.text.bodySmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
