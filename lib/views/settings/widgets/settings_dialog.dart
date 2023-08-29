import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';

import 'mode_child.dart';

class SettingsDialog<T> extends StatefulWidget {
  final T value;
  final List<T> values;
  final List<String> labels;
  final Function(T)? onSelected;
  final String title;
  const SettingsDialog({
    super.key,
    required this.values,
    required this.value,
    required this.labels,
    required this.title,
    this.onSelected,
  }) : assert(
          values.length == labels.length,
          "labels and values should be thesame lenght",
        );

  @override
  State<SettingsDialog<T>> createState() => SettingsDialogState<T>();
}

class SettingsDialogState<T> extends State<SettingsDialog<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 300,
        height: 50.0 + (50 * (widget.values.length)),
        padding: ($styles.insets.md, 0.0).insets,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular($styles.corners.md),
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.bottomLeft,
              margin: $styles.insets.xs.insetsBottom,
              child: Text(
                widget.title,
                style: $styles.text.bodyBold,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  for (var i = 0; i < widget.values.length; i++)
                    ModeChild<T>(
                      label: widget.labels[i],
                      value: widget.values[i],
                      selected: _selectedValue as T,
                      onSelected: (value) {
                        _selectedValue = value;
                        widget.onSelected?.call(_selectedValue as T);
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
