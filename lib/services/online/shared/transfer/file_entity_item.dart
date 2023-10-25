import 'dart:io';

import 'package:mime/mime.dart';

import 'item.dart';

abstract class FileEntityItem extends Item {
  FileEntityItem({
    required FileSystemEntity fileSystemEntity,
    required String id,
    required String fileType,
    required int fileSize,
    required String? fileName,
    required String authorId,
    (String, int)? homeDestination,
  }) : super(
          authorId: authorId,
          fileSize: fileSize,
          fileType: fileType,
          fileSystemEntity: fileSystemEntity,
          homeDestination: homeDestination,
          id: id,
          fileName: fileName,
        );

  @override
  String? get mime => lookupMimeType(fileSystemEntity.path);

  @override
  String get name => fileName ?? fileSystemEntity.path.split("/").last;

  @override
  String get filePath => fileSystemEntity.path;
}
