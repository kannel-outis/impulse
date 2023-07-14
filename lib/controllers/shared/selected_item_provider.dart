import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/services/services.dart';
import 'package:impulse_utils/impulse_utils.dart';
import 'package:uuid/uuid.dart';

final selectedItemsProvider =
    StateNotifierProvider<SelectedItems, List<Item>>((ref) {
  final serverController = ref.watch(serverControllerProvider);
  return SelectedItems(
    serverManager: serverController,
  );
});

class SelectedItems extends StateNotifier<List<Item>> {
  final ServerManager serverManager;
  SelectedItems({
    List<File> initialList = const [],
    required this.serverManager,
  }) : super([]);
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
    _updateServerList();
  }

  void removeSelected({String? path, File? file}) {
    if (path != null) {
      items.removeWhere((element) => element.file.path == path);
    } else {
      items.removeWhere((element) => element.file.path == file!.path);
    }
    state = [...items];
    log(items.length.toString());
    _updateServerList();
  }

  void _updateServerList() {
    serverManager.setSelectedItems(state);
  }

  ShareableItem itemFromFile(File file) {
    return ShareableItem(
        file: file,
        fileType: file.path.getFileType.type,
        fileSize: file.lengthSync(),
        id: const Uuid().v4(),

        ///Home destination is my server
        homeDestination: (serverManager.ipAddress!, serverManager.port!),
        authorId: "22002222000");
  }

  bool get selectedIsEmpty => items.isEmpty;
}
