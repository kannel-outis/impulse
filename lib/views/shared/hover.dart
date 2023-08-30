import 'package:flutter/material.dart';

class Hover extends StatefulWidget {
  final Widget child;
  final Function(bool)? onHover;
  final MouseCursor cursor;
  const Hover({
    super.key,
    required this.child,
    this.cursor = SystemMouseCursors.basic,
    this.onHover,
  });

  @override
  State<Hover> createState() => _HoverState();
}

class _HoverState extends State<Hover> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (event) {
        widget.onHover?.call(true);
      },
      onExit: (event) {
        widget.onHover?.call(false);
      },
      child: widget.child,
    );
  }
}
