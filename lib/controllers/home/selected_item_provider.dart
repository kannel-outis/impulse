import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';

final selectedItemsProvider =
    StateNotifierProvider<SelectedItems, List<File>>((ref) => SelectedItems());

class SelectedItems extends StateNotifier<List<File>> {
  SelectedItems({List<File> initialList = const []}) : super([]);
  final items = <File>[];

  void addSelected({File? file, String? path}) {
    if (path == null && file == null) {
      onError?.call(const AppException("Invalid Selected item"), null);
      return;
    }
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        items.add(file);
      }
    } else {
      if (file != null) {
        items.add(file);
      }
    }
    state = [...items];
  }

  void removeSelected({String? path, File? file}) {
    if (path != null) {
      items.removeWhere((element) => element.path == path);
    } else {
      items.removeWhere((element) => element.path == file!.path);
    }
    state = [...items];
    log(items.length.toString());
  }

  bool get selectedIsEmpty => items.isEmpty;
}
