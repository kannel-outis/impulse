import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';

class ConnectedFABLocation extends StandardFabLocation {
  const ConnectedFABLocation();
  final fabSize = 50;
  final bottomNavBarHeight = 70;
  //since we want it to stay on top of the mini player
  final miniPlayerMinHeight = 70;
  @override
  double getOffsetX(
      ScaffoldPrelayoutGeometry scaffoldGeometry, double adjustment) {
    final padding = ($styles.insets.md * 2);
    return scaffoldGeometry.scaffoldSize.width - padding - fabSize + adjustment;
  }

  @override
  double getOffsetY(
      ScaffoldPrelayoutGeometry scaffoldGeometry, double adjustment) {
    return scaffoldGeometry.scaffoldSize.height -
        fabSize +
        adjustment -
        (bottomNavBarHeight + miniPlayerMinHeight);
  }
}
