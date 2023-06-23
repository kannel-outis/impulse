import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectingItemStateProvider =
    ChangeNotifierProvider<SelectingItemState>((ref) => SelectingItemState());

class SelectingItemState extends ChangeNotifier {
  bool _isSelectingApp = false;
  bool get isSelectingApp => _isSelectingApp;
  set isSelectingApp(bool isSelecting) {
    _isSelectingApp = isSelecting;
    notifyListeners();
  }
}
