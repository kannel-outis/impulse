import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/models/models.dart';
import 'package:impulse/services/services.dart';
import 'package:impulse_utils/impulse_utils.dart';
import 'package:uuid/uuid.dart';

final selectedItemsProvider =
    StateNotifierProvider<SelectedItems, List<Item>>((ref) {
  final serverinfo = ref.watch(connectUserStateProvider);
  return SelectedItems(destination: serverinfo);
});

class SelectedItems extends StateNotifier<List<Item>> {
  final ServerInfo? destination;
  SelectedItems({List<File> initialList = const [], this.destination})
      : super([]);
  final items = <ShareableItem>[];

  void addSelected({File? file, String? path}) {
    if (path == null && file == null) {
      onError?.call(const AppException("Invalid Selected item"), null);
      return;
    }
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        final item = itemFromFile(file);
        items.add(item);
      }
    } else {
      if (file != null) {
        final item = itemFromFile(file);
        items.add(item);
        // items.add(file);
      }
    }
    state = [...items];
  }

  void removeSelected({String? path, File? file}) {
    if (path != null) {
      items.removeWhere((element) => element.file.path == path);
    } else {
      items.removeWhere((element) => element.file.path == file!.path);
    }
    state = [...items];
    log(items.length.toString());
  }

  ShareableItem itemFromFile(File file) {
    return ShareableItem(
        file: file,
        fileType: file.path.getFileType.type,
        fileSize: file.lengthSync(),
        id: const Uuid().v4(),
        // destination: (destination!.ipAddress!, destination!.port!),
        authorId: "22002222000");
  }

  bool get selectedIsEmpty => items.isEmpty;
}
