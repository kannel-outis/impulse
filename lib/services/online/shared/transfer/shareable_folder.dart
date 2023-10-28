part of 'shareable_item.dart';

class _ShareableFolder extends ShareableItem
    with MultipleItemsStart<UploaderItem> {
  final Directory dir;
  _ShareableFolder({
    required this.dir,
    required String fileType,
    required String authorId,
    required int fileSize,
    required String id,
    (String, int)? homeDestination,
    String? altName,
  }) : super(
          authorId: authorId,
          file: dir,
          fileSize: fileSize,
          fileType: fileType,
          id: id,
          altName: altName,
          homeDestination: homeDestination,
        );

  final items = <UploaderItem>[];

  @override
  List<UploaderItem> get files => items;

  // ({int index, int fileProccessed}) get _start => startPosition(sentBytes);

  void _listener(int received, int totalSize, FileSystemEntity? file,
      String? reason, IState state) {
    sentBytes += received;
    notifyListeners(sentBytes, totalSize, dir, reason, state);
  }

  @override
  Future<void> upload(Future Function(Stream<List<int>> data) future,
      {int start = 0, Function(int p1)? onDone}) async {
    final start0 = startPosition(start);
    for (var i = start0.index; i < items.length; i++) {
      final item = items[i]
        ..sentBytes += start0.fileProccessed
        ..addListener(_listener);

      // int bytesDownloadedByClient = start;
      await item.upload(future, start: start0.fileProccessed);
      item.removeListener(_listener);
    }
  }

  @override
  Future<Map<String, dynamic>> toMap() async {
    if (FileSystemEntity.isLinkSync(dir.path)) {
      return {
        "folder": {
          "group_id": id,
          "meta_data": ((await super.toMap())["file"] as Map<String, dynamic>)
            ..["fileSize"] = 0,
          "size": 0,
          "item_count": 0,
          "files": [],
        },
      };
    }
    final listSync = dir.listSync();
    final mapList = <Map<String, dynamic>>[];
    for (var item in listSync) {
      if (item is File) {
        final file = ShareableItem.file(
          file: item,
          fileType: item.path.getFileType.type,
          fileSize: await item.size(),
          id: const Uuid().v4(),
          // altName: altName,
          authorId: authorId,
          homeDestination: homeDestination,
        );
        items.add(file);
        mapList.add(await file.toMap());
      } else {
        final folder = ShareableItem.folder(
          dir: item as Directory,
          fileType: "folder",
          fileSize: await item.size(),
          id: const Uuid().v4(),
          authorId: authorId,
          homeDestination: homeDestination,
        );
        items.add(folder);
        mapList.add(await folder.toMap());
      }
    }
    return {
      "folder": {
        "group_id": id,
        "meta_data": ((await super.toMap())["file"] as Map<String, dynamic>)
          ..["fileSize"] = await dir.size(),
        "size": await dir.size(),
        "item_count": mapList.length,
        "files": mapList,
      },
    };
  }
}
