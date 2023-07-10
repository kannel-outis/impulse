import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/shared/selected_item_provider.dart';
import 'package:impulse/controllers/shared/selecting_item_provider.dart';
import 'package:impulse_utils/impulse_utils.dart';

class AppItem extends ConsumerStatefulWidget {
  final Application app;
  const AppItem({
    super.key,
    required this.app,
  });

  @override
  ConsumerState<AppItem> createState() => _AppItemState();
}

class _AppItemState extends ConsumerState<AppItem> {
  double _appBox() {
    final screenWidth = MediaQuery.of(context).size.width;

    ///The total width of device minus the padding on both side
    ///divided by the number of items we'd like to fit in a row
    return (screenWidth - ($styles.insets.md * 2)) / 4;
  }

  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    final selectingItemPRovider = ref.watch(selectingItemStateProvider);
    final selectedItems = ref.read(selectedItemsProvider.notifier);
    return GestureDetector(
      onLongPress: () {
        ///if Already in selecting mode, cancel
        if (selectingItemPRovider.isSelectingApp) return;

        /// enter selecting mode
        /// and add the first item
        selectingItemPRovider.isSelectingApp = true;
        selectedItems.addSelected(path: widget.app.appPath);
        _isSelected = true;
        setState(() {});
      },
      onTap: () {
        if (selectingItemPRovider.isSelectingApp) {
          ///Adds to selected apps or remove app if already added
          if (_isSelected == false) {
            selectedItems.addSelected(path: widget.app.appPath);
            _isSelected = true;
            setState(() {});
          } else {
            selectedItems.removeSelected(path: widget.app.appPath);
            _isSelected = false;
            setState(() {});
          }

          if (selectedItems.selectedIsEmpty) {
            selectingItemPRovider.isSelectingApp = false;
          }
        }
      },
      child: Container(
        width: _appBox(),
        height: _appBox(),
        color: _isSelected ? Colors.white : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular($styles.corners.md),
                image: DecorationImage(
                  image: MemoryImage(widget.app.appIcon),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
              widget.app.appName,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: $styles.text.body,
            ),
            Text(
              widget.app.sizeToString,
              textAlign: TextAlign.center,
              style: $styles.text.body,
            ),
          ],
        ),
      ),
    );
  }
}
