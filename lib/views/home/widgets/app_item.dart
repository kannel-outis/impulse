import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse_utils/impulse_utils.dart';

class AppItem extends StatefulWidget {
  const AppItem({
    super.key,
    required this.app,
  });

  final Application app;

  @override
  State<AppItem> createState() => _AppItemState();
}

class _AppItemState extends State<AppItem> {
  double _appBox() {
    final screenWidth = MediaQuery.of(context).size.width;

    ///The total width of device minus the padding on both side
    ///divided by the number of items we'd like to fit in a row
    return (screenWidth - ($styles.insets.md * 2)) / 4;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: _appBox(),
      width: _appBox(),
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
    );
  }
}
