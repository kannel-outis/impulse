import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';

class ModeChild extends StatefulWidget {
  final ThemeMode selected;
  final ThemeMode value;
  final String label;
  final Function(ThemeMode)? onSelected;
  const ModeChild({
    super.key,
    required this.selected,
    required this.value,
    required this.label,
    this.onSelected,
  });

  @override
  State<ModeChild> createState() => _ModeChildState();
}

class _ModeChildState extends State<ModeChild> {
  ThemeMode _selected = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  void didUpdateWidget(covariant ModeChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _selected = widget.selected;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (widget.value == widget.selected) return;
          widget.onSelected?.call(widget.value);
        },
        child: SizedBox(
          height: 40,
          child: Row(
            children: [
              Radio<ThemeMode>(
                value: widget.value,
                groupValue: _selected,
                onChanged: (value) {
                  // print("object");
                  // if (value == null) return;
                  // _selected = value;
                  // setState(() {});
                },
              ),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: $styles.text.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
