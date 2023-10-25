// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse_utils/impulse_utils.dart';

import 'state_listenable.dart';

// ignore: must_be_immutable
abstract class Item extends StateListenable with EquatableMixin {
  final String id;
  final FileSystemEntity fileSystemEntity;
  final String fileType;
  final int fileSize;
  final String? fileName;
  final String authorId;
  (String, int)? homeDestination;

  Item({
    required this.fileSystemEntity,
    required this.fileType,
    required this.fileSize,
    required this.id,
    required this.authorId,
    required this.homeDestination,
    this.fileName,
  });
  DateTime? startTime;

  DateTime _endTime = DateTime.now();
  DateTime get endTime => _endTime;
  set setEndTime(DateTime endtime) {
    _endTime = endtime;
  }

  // String? get mime => lookupMimeType(file.path);

  // String get name => fileName ?? file.path.split("/").last;

  // String get filePath => file.path;

  String? get mime;

  String get name;

  String get filePath;

  IState get state;

  int get proccessedBytes;

  int get remainingBytes => fileSize - proccessedBytes;

  _ItemFileSize get itemSize => _ItemFileSize(fileSize);

  Future<Map<String, dynamic>> toMap() async {
    return {
      "file": {
        "path": filePath,
        "fileSize": fileSize,
        "fileType": fileType,
        "fileId": id,
        "senderId": authorId,
        "fileName": fileName,
        // check later
        "altName": fileName,
        "homeDestination": {
          "ip": homeDestination!.$1,
          "port": homeDestination!.$2,
        }
      }
    };
  }
}

class _ItemFileSize extends FileSize {
  const _ItemFileSize(super.size);
}
