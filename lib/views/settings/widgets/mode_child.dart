import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/views/shared/impulse_ink_well.dart';

class ModeChild<T> extends StatefulWidget {
  final T selected;
  final T value;
  final String label;
  final Function(T)? onSelected;
  const ModeChild({
    super.key,
    required this.selected,
    required this.value,
    required this.label,
    this.onSelected,
  });

  @override
  State<ModeChild<T>> createState() => _ModeChildState<T>();
}

class _ModeChildState<T> extends State<ModeChild<T>> {
  T? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  void didUpdateWidget(covariant ModeChild<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _selected = widget.selected;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ImpulseInkWell(
      onTap: () {
        if (widget.value == widget.selected) return;
        widget.onSelected?.call(widget.value);
      },
      child: Container(
        color: Colors.transparent,
        height: 40,
        child: Row(
          children: [
            Radio<T>(
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
    );
  }
}
