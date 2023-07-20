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

  void addSelected({File? file, String? path, String? altName}) async {
    if (path == null && file == null) {
      onError?.call(const AppException("Invalid Selected item"), null);
      return;
    }
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        final item = await itemFromFile(file, altName);
        items.add(item);
      }
    } else {
      if (file != null) {
        final item = await itemFromFile(file, altName);
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

  void clear() {
    state = [];
  }

  Future<ShareableItem> itemFromFile(File file, [String? altName]) async {
    final myInfo = await serverManager.myServerInfo();
    return ShareableItem(
      file: file,
      fileType: file.path.getFileType.type,
      fileSize: file.lengthSync(),
      id: const Uuid().v4(),
      altName: altName,

      ///Home destination is my server
      homeDestination: (serverManager.ipAddress!, serverManager.port!),
      authorId: myInfo.user.id,
    );
  }

  bool get selectedIsEmpty => items.isEmpty;
}

final shareableItemsProvider =
    StateNotifierProvider<ShareableItemsProvider, List<ShareableItem>>(
        (ref) => ShareableItemsProvider());

class ShareableItemsProvider extends StateNotifier<List<ShareableItem>> {
  ShareableItemsProvider() : super([]);
  List<Item> _filtered = [];

  void addAllItems(List<Item> items) {
    state = [...state, ..._filteredList(items)];
  }

  List<Item> get filteredList => _filtered;

  ///filter list so that they are not sent more than once
  List<ShareableItem> _filteredList(List<Item> items) {
    return _filtered = items
        .map((e) => e as ShareableItem)
        .toList()
        .where((element) =>
            !state.map((e) => e.id).toList().contains(element.id) &&
            !state.map((e) => e.filePath).toList().contains(element.filePath))
        .toList();
  }
}
