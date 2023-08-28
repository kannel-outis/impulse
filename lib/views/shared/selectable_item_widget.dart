import 'dart:io';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/views/shared/hover.dart';
import 'package:impulse/views/shared/sizer.dart';
import 'package:impulse_utils/impulse_utils.dart';

class SelectableItemWidget extends ConsumerStatefulWidget {
  final Application? app;
  final File? file;
  final Widget child;
  final bool isSelectable;
  final Alignment alignment;
  final Function(bool)? onChanged;
  const SelectableItemWidget({
    super.key,
    this.app,
    this.file,
    this.alignment = const Alignment(.95, 0.0),
    this.isSelectable = false,
    required this.child,
    this.onChanged,
  });

  @override
  ConsumerState<SelectableItemWidget> createState() =>
      _SelectableItemWidgetState();
}

class _SelectableItemWidgetState extends ConsumerState<SelectableItemWidget> {
  bool _isSelected = false;
  bool _onHover = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.file != null) {
        ///because of listview.builder, we lose the state of this widget when its not in the viewport,
        ///thus, losing the state of [_isSelected]. we have to check it as soon as it comes back into
        ///the viewport if it was selected already
        if (ref
            .read(selectedItemsProvider.notifier)
            .items
            .map((e) => e.filePath)
            .contains(widget.file!.path)) {
          _isSelected = true;
          setState(() {});
        }
      }
    });
  }

  double _height = 0;

  @override
  void didUpdateWidget(covariant SelectableItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.file == null) return;
      if (ref
          .read(selectedItemsProvider.notifier)
          .items
          .map((e) => e.filePath)
          .contains(widget.file!.path)) {
        _isSelected = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedItemsProvider, (previous, next) {
      if (next.isEmpty) {
        ref.read(selectingItemStateProvider).isSelectingApp = false;
        _isSelected = false;
      }
    });

    return Hover(
      onHover: (hover) {
        _onHover = hover;
        setState(() {});
      },
      child: GestureDetector(
        onLongPress: () {
          ///if platform is desktop, we dont want longpress to happen
          if (Platform.isWindows || Platform.isLinux) return;
          _onLongPress(ref);
        },
        onTap: () {
          ///if platform is desktop, we dont want tap to happen
          if (Platform.isWindows || Platform.isLinux) return;
          _onTap(ref, !_isSelected);
        },
        child: Container(
          decoration: BoxDecoration(
            color: _onHover ? Theme.of(context).hoverColor : Colors.transparent,
          ),
          child: widget.isSelectable
              ? Consumer(
                  child: widget.child,
                  builder: (context, ref, child) {
                    final selectingItemPRovider =
                        ref.watch(selectingItemStateProvider);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Sizer(
                          child: child!,
                          onSize: (size) {
                            _height = size.height;
                            setState(
                              () {},
                            );
                          },
                        ),
                        if (_onHover || selectingItemPRovider.isSelectingApp)
                          SizedBox(
                            height: _height,
                            child: Align(
                              alignment: widget.alignment,
                              child: Checkbox(
                                value: _isSelected,
                                checkColor:
                                    Theme.of(context).colorScheme.surface,
                                side: BorderSide(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!,
                                ),
                                activeColor:
                                    Theme.of(context).colorScheme.secondary,
                                onChanged: (value) {
                                  if (value != null) {
                                    final selectingItemPRovider =
                                        ref.read(selectingItemStateProvider);

                                    if (widget.isSelectable == false) return;

                                    if (selectingItemPRovider.isSelectingApp) {
                                      ///Adds to selected apps or remove app if already added
                                      _onTap(ref, value);
                                    } else {
                                      _onLongPress(ref);
                                    }
                                    if (ref
                                        .read(selectedItemsProvider)
                                        .isEmpty) {
                                      selectingItemPRovider.isSelectingApp =
                                          false;
                                    }
                                  }
                                },
                              ),
                            ),
                          )
                      ],
                    );
                  },
                )
              : widget.child,
        ),
      ),
    );
  }

  void _onLongPress(WidgetRef ref) {
    final selectingItemPRovider = ref.read(selectingItemStateProvider);
    final selectedItems = ref.read(selectedItemsProvider.notifier);

    ///if Already in selecting mode, cancel
    if (widget.isSelectable == false) return;
    if (selectingItemPRovider.isSelectingApp) return;

    /// enter selecting mode
    /// and add the first item
    selectingItemPRovider.isSelectingApp = true;
    selectedItems.addSelected(
      path: widget.app?.appPath,
      file: widget.file,
      altName: widget.app?.appName,
    );
    _isSelected = true;
    widget.onChanged?.call(_isSelected);
    setState(() {});
  }

  void _onTap(WidgetRef ref, bool value) {
    final selectingItemPRovider = ref.read(selectingItemStateProvider);
    final selectedItems = ref.read(selectedItemsProvider.notifier);
    if (widget.isSelectable == false) return;
    if (selectingItemPRovider.isSelectingApp) {
      ///Adds to selected apps or remove app if already added
      if (value) {
        selectedItems.addSelected(
          path: widget.app?.appPath,
          file: widget.file,
          altName: widget.app?.appName,
        );
      } else {
        selectedItems.removeSelected(
          path: widget.app?.appPath,
          file: widget.file,
        );
      }
      _isSelected = value;
      widget.onChanged?.call(_isSelected);

      setState(() {});
    }
  }
}
