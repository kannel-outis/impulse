part of 'shareable_item.dart';

class _ShareableFolder extends ShareableItem {
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

  final items = <ShareableItem>[];

  @override
  Future<Map<String, dynamic>> toMap() async {
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

  @override
  Future<void> upload(Future Function(Stream<List<int>> data) future,
      {int start = 0, Function(int p1)? onDone}) async {}
}
