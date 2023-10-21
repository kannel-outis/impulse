import 'dart:io';

import 'package:mime/mime.dart';

import 'item.dart';

abstract class FileEntityItem extends Item {
  FileEntityItem({
    required FileSystemEntity file,
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
          file: file,
          homeDestination: homeDestination,
          id: id,
          fileName: fileName,
        );

  @override
  String? get mime => lookupMimeType(file.path);

  @override
  String get name => fileName ?? file.path.split("/").last;

  @override
  String get filePath => file.path;
}
