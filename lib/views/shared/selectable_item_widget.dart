import 'dart:io';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/utils/enums.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse_utils/impulse_utils.dart';

class SelectableItemWidget extends ConsumerStatefulWidget {
  final Application? app;
  final File? file;
  final Widget child;
  const SelectableItemWidget({
    super.key,
    this.app,
    this.file,
    required this.child,
  });

  @override
  ConsumerState<SelectableItemWidget> createState() =>
      _SelectableItemWidgetState();
}

class _SelectableItemWidgetState extends ConsumerState<SelectableItemWidget> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

    // });
  }

  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedItemsProvider, (previous, next) {
      if (next.isEmpty) {
        ref.read(selectingItemStateProvider).isSelectingApp = false;
        _isSelected = false;
      }
    });
    final selectingItemPRovider = ref.watch(selectingItemStateProvider);
    final selectedItems = ref.watch(selectedItemsProvider.notifier);
    return GestureDetector(
      onLongPress: () {
        if (widget.file == null && widget.app == null ||
            ref.read(connectionStateProvider) != ConnectionState.connected) {
          return;
        }

        ///if Already in selecting mode, cancel
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
        setState(() {});
      },
      onTap: () {
        print("object");
        if (selectingItemPRovider.isSelectingApp) {
          ///Adds to selected apps or remove app if already added
          if (_isSelected == false) {
            selectedItems.addSelected(
              path: widget.app?.appPath,
              file: widget.file,
              altName: widget.app?.appName,
            );
            _isSelected = true;
            setState(() {});
          } else {
            selectedItems.removeSelected(
              path: widget.app?.appPath,
              file: widget.file,
            );
            _isSelected = false;
            setState(() {});
          }
        }
        if (ref.read(selectedItemsProvider).isEmpty) {
          selectingItemPRovider.isSelectingApp = false;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: _isSelected ? Colors.white : Colors.transparent,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
