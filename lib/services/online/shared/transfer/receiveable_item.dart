// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'dart:async';
import 'dart:developer';

import 'package:impulse/app/app.dart';
import 'package:impulse/services/online/shared/transfer/multipl_items_start_mixin.dart';
import 'package:impulse/services/services.dart';

part 'receiveable_folder.dart';
part 'receiveable_file.dart';

abstract class ReceiveableItem extends ReceiverItem {
  final String? altName;

  ReceiveableItem({
    required FileSystemEntity file,
    required String fileType,
    required int fileSize,
    required String id,
    required (String, int) homeDestination,
    required String authorId,
    this.altName,
  }) : super(
          id: id,
          fileSystemEntity: file,
          fileSize: fileSize,
          authorId: authorId,
          fileType: fileType,
          homeDestination: homeDestination,
          fileName: file.path.split(Platform.pathSeparator).last,
        );

  factory ReceiveableItem.fromItemShareableMap(Map<String, dynamic> nMap) {
    final map = nMap["file"] as Map<String, dynamic>;
    final metaData = _MetaData.fromMap(map);

    final fileName = metaData.altName != null
        ? _joinNameWithId(metaData.altName as String, metaData.id)
        : _joinNameWithId(metaData.altName as String, metaData.id);
    return ReceiveableItem.item(
      file: File("${Configurations.instance.impulseDir!.path}$fileName"),
      fileType: metaData.fileType,
      fileSize: metaData.fileSize,
      id: metaData.id,
      altName: metaData.altName,
      homeDestination: metaData.homeDestination,
      authorId: metaData.senderId,
    );
  }

  static Future<ReceiveableItem> fromFolderShareableMap(
      Map<String, dynamic> nMap) async {
    final map = nMap["folder"] as Map<String, dynamic>;
    final metaData = _MetaData.fromMap(map);
    return ReceiveableItem.folder(
      dir: Directory(metaData.filePath),
      items: await _MetaData._items(map),
      fileType: metaData.fileType,
      fileSize: metaData.fileSize,
      id: metaData.id,
      altName: metaData.altName,
      homeDestination: metaData.homeDestination,
      authorId: metaData.senderId,
    );
  }

  static String _joinNameWithId(String name, String id) {
    ///Storing with individual ids to avoid problems with app or file with the same name,
    final list = (name).split(".");
    list.insert(1, id);
    return list.join(".");
  }

  factory ReceiveableItem.folder({
    required List<ReceiverItem> items,
    required Directory dir,
    required String fileType,
    required int fileSize,
    required String id,
    int proccessed = 0,
    required (String, int) homeDestination,
    required String authorId,
    String? altName,
  }) =>
      _ReceiveableFolder(
        groupId: id,
        itemCount: items.length,
        items: items,
        metaData: _MetaData(
          fileName: "",
          filePath: dir.path,
          fileSize: fileSize,
          fileType: fileType,
          homeDestination: homeDestination,
          id: id,
          senderId: authorId,
          altName: altName,
        ),
        start: proccessed,
      );

  factory ReceiveableItem.item({
    required File file,
    required String fileType,
    required int fileSize,
    required String id,
    int proccessed = 0,
    required (String, int) homeDestination,
    required String authorId,
    String? altName,
  }) =>
      _ReceiveableFile(
        authorId: authorId,
        file: file,
        fileType: fileType,
        homeDestination: homeDestination,
        id: id,
        altName: altName,
        fileSize: fileSize,
      )..start = proccessed;

  bool get isFile => this is _ReceiveableFile;
  bool get isFolder => this is _ReceiveableFolder;
  _ReceiveableFile get asFile => this as _ReceiveableFile;
  _ReceiveableFolder get asFolder => this as _ReceiveableFolder;
}

class _MetaData {
  final String filePath;
  final int fileSize;
  final String id;
  final String senderId;
  final String fileName;
  final String fileType;
  final (String, int) homeDestination;
  final String? altName;
  const _MetaData({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.fileType,
    required this.homeDestination,
    required this.id,
    required this.senderId,
    required this.altName,
  });

  factory _MetaData.fromMap(Map<String, dynamic> map) {
    return _MetaData(
      fileName: map["fileName"] as String,
      filePath: map["path"] as String,
      fileSize: map["fileSize"] as int,
      fileType: map["fileType"] as String,
      altName: map["altName"] as String,
      homeDestination: (
        map["homeDestination"]["ip"] as String,
        map["homeDestination"]["port"] as int,
      ),
      id: map["fileId"] as String,
      senderId: map["senderId"] as String,
    );
  }
  static Future<List<ReceiverItem>> _items(Map<String, dynamic> map) async {
    final completer = Completer<List<ReceiverItem>>();
    final list = map["folder"]["files"] as List<Map<String, dynamic>>;
    final itemStream = _itemStream(list);
    int count = 0;
    await for (final _ in itemStream) {
      count += 1;
      if (count == list.length) completer.complete(itemStream.toList());
    }
    return await completer.future;
  }

  static Stream<ReceiverItem> _itemStream(
      List<Map<String, dynamic>> list) async* {
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      if (item.containsKey("folder")) {
        yield await ReceiveableItem.fromFolderShareableMap(item);
      } else {
        yield ReceiveableItem.fromItemShareableMap(item);
      }
    }
  }
}
