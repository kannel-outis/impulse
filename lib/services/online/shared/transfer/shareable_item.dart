import 'package:impulse/app/app.dart';
import 'package:impulse/services/services.dart';
import 'package:impulse_utils/impulse_utils.dart';
import 'package:uuid/uuid.dart';

import 'file_entity_item.dart';

// ignore: must_be_immutable
class ShareableItem extends FileEntityItem {
  final String? altName;
  ShareableItem({
    required FileSystemEntity file,
    required String fileType,
    required int fileSize,
    required String id,
    (String, int)? homeDestination,
    this.altName,
    required String authorId,
  }) : super(
          id: id,
          file: file,
          fileSize: fileSize,
          fileType: fileType,
          authorId: authorId,
          homeDestination: homeDestination,
          fileName: altName ?? file.path.split(Platform.pathSeparator).last,
        );

  factory ShareableItem.fromMap(Map<String, dynamic> map) {
    return ShareableItem(
      file: File(map["path"] as String),
      fileType: map["fileType"] as String,
      fileSize: map["fileSize"] as int,
      id: map["fileId"] as String,
      authorId: map["senderId"] as String,
      altName: map["altName"] as String?,
      homeDestination: (
        map["homeDestination"]["ip"] as String,
        map["homeDestination"]["port"] as int
      ),
    );
  }

  factory ShareableItem.folder({
    required Directory dir,
    required String fileType,
    required int fileSize,
    required String id,
    (String, int)? homeDestination,
    String? altName,
    required String authorId,
  }) =>
      _ShareableFolder(
        dir: dir,
        authorId: authorId,
        fileSize: fileSize,
        fileType: fileType,
        id: id,
        altName: altName,
      );

  IState _state = IState.pending;

  int sentBytes = 0;

  ///should be called from the server
  void updateProgress(int received, int totalSize, IState state) {
    _state = state;
    sentBytes = received;
    notifyListeners(received, totalSize, file, "", state);
  }

  @override
  int get proccessedBytes => sentBytes;

  @override
  IState get state => _state;

  @override
  List<Object?> get props => [
        fileSize,
        fileType,
        id,
        fileName,
        authorId,
        filePath,
      ];

  // @override
  // String? get mime => lookupMimeType(file.path);

  // @override
  // String get name => fileName ?? file.path.split("/").last;

  // @override
  // String get filePath => file.path;
}

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

  @override
  Future<Map<String, dynamic>> toMap() async {
    final listSync = dir.listSync();
    final mapList = <Map<String, dynamic>>[];
    int size = 0;
    for (var item in listSync) {
      final stat = await item.stat();
      size += stat.size;
      if (item is File) {
        mapList.add(
          await ShareableItem(
            file: item,
            fileType: item.path.getFileType.type,
            fileSize: stat.size,
            id: const Uuid().v4(),
            // altName: altName,
            authorId: authorId,
            homeDestination: homeDestination,
          ).toMap(),
        );
      } else {
        mapList.add(
          await ShareableItem.folder(
            dir: item as Directory,
            fileType: "folder",
            fileSize: stat.size,
            id: const Uuid().v4(),
            authorId: authorId,
            homeDestination: homeDestination,
          ).toMap(),
        );
      }
    }
    return {
      "folder": {
        "group_id": id,
        "meta_data": ((await super.toMap())["file"] as Map<String, dynamic>)
          ..["fileSize"] = size,
        "size": size,
        "item_count": mapList.length,
        "files": mapList,
      },
    };
  }
}
