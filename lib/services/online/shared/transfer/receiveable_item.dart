// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:impulse/app/app.dart';
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
          file: file,
          fileSize: fileSize,
          authorId: authorId,
          fileType: fileType,
          homeDestination: homeDestination,
          fileName: file.path.split(Platform.pathSeparator).last,
        );

  factory ReceiveableItem.fromItemShareableMap(Map<String, dynamic> nMap) {
    final map = nMap["file"] as Map<String, dynamic>;
    final fileName = map["altName"] != null
        ? _joinNameWithId(map["altName"] as String, map["fileId"] as String)
        : _joinNameWithId(map["fileName"] as String, map["fileId"] as String);
    return ReceiveableItem.item(
      file: File("${Configurations.instance.impulseDir!.path}$fileName"),
      fileType: map["fileType"] as String,
      fileSize: map["fileSize"] as int,
      id: map["fileId"] as String,
      altName: map["altName"],
      homeDestination: (
        map["homeDestination"]["ip"] as String,
        map["homeDestination"]["port"] as int
      ),
      authorId: map["senderId"],
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
        authorId: authorId,
        file: dir,
        fileType: fileType,
        homeDestination: homeDestination,
        id: id,
        items: items,
        altName: altName,
        fileSize: fileSize,
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
      _ReceiveableItem(
        authorId: authorId,
        file: file,
        fileType: fileType,
        homeDestination: homeDestination,
        id: id,
        altName: altName,
        fileSize: fileSize,
        // start: proccessed,
      );
}
