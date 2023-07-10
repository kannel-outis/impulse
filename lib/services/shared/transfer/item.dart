import 'dart:io';

import 'package:impulse/services/utils/enums.dart';

typedef OnProgressCallBack = Function(
  int received,
  int totalSize,
  TransferState state,
);

typedef OnStateChange = Function(
  int received,
  int totalSize,
  File? file,
  String? reason,
  TransferState state,
);

abstract class Item {
  final String id;
  final File file;
  final String fileType;
  final int fileSize;
  final OnProgressCallBack? onProgressCallback;
  final OnStateChange? onStateChange;

  Item({
    required this.file,
    required this.fileType,
    required this.fileSize,
    required this.id,
    this.onProgressCallback,
    this.onStateChange,
  });

  Future<void> share() async {
    throw UnimplementedError();
  }

  Future<void> cancel() async {
    throw UnimplementedError();
  }

  Future<void> pause() async {
    throw UnimplementedError();
  }

  TransferState get state;
}
