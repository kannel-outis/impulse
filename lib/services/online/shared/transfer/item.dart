import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse_utils/impulse_utils.dart';
import 'package:mime/mime.dart';

import 'state_listenable.dart';

// ignore: must_be_immutable
abstract class Item extends StateListenable with EquatableMixin {
  final String id;
  final File file;
  final String fileType;
  final int fileSize;
  final String? fileName;
  // OnProgressCallBack? onProgressCallback;
  // OnStateChange? onStateChange;
  final String authorId;
  final (String, int) homeDestination;

  Item({
    required this.file,
    required this.fileType,
    required this.fileSize,
    required this.id,
    required this.authorId,
    required this.homeDestination,
    // this.onProgressCallback,
    // this.onStateChange,
    this.fileName,
  });
  DateTime? startTime;

  Future<void> receive() async {
    throw UnimplementedError();
  }

  Future<void> cancel() async {
    throw UnimplementedError();
  }

  Future<void> pause() async {
    throw UnimplementedError();
  }

  // IState get state;

  String? get mime => lookupMimeType(file.path);

  String get name => fileName ?? file.path.split("/").last;

  String get filePath => file.path;

  IState get state;

  int get proccessedBytes;

  // ignore: library_private_types_in_public_api
  _ItemFileSize get itemSize => _ItemFileSize(fileSize);

  Map<String, dynamic> toMap();
}

class _ItemFileSize extends FileSize {
  const _ItemFileSize(super.size);
}
