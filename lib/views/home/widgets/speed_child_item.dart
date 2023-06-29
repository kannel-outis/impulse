import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';

class SpeedChild extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  const SpeedChild({
    super.key,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Icon(
            icon,
            size: 25,
          ),
        ),
      ),
    );
  }
}
