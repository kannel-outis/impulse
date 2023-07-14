import 'dart:io';

import 'package:impulse/services/utils/enums.dart';
import 'package:mime/mime.dart';

typedef OnProgressCallBack = Function(
  int received,
  int totalSize,
  DownloadState state,
);

typedef OnStateChange = Function(
  int received,
  int totalSize,
  File? file,
  String? reason,
  DownloadState state,
);

abstract class Item {
  final String id;
  final File file;
  final String fileType;
  final int fileSize;
  final String? fileName;
  final OnProgressCallBack? onProgressCallback;
  final OnStateChange? onStateChange;
  final String authorId;
  final (String, int) homeDestination;

  Item({
    required this.file,
    required this.fileType,
    required this.fileSize,
    required this.id,
    required this.authorId,
    required this.homeDestination,
    this.onProgressCallback,
    this.onStateChange,
    this.fileName,
  });

  Future<void> receive() async {
    throw UnimplementedError();
  }

  Future<void> cancel() async {
    throw UnimplementedError();
  }

  Future<void> pause() async {
    throw UnimplementedError();
  }

  // DownloadState get state;

  String? get mime => lookupMimeType(file.path);

  String get name => fileName ?? file.path.split("/").last;

  Map<String, dynamic> toMap();
}
