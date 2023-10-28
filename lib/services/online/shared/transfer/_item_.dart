import "package:impulse/app/app.dart";
import 'package:impulse/services/online/shared/transfer/file_entity_item.dart';

abstract class ReceiverItem extends FileEntityItem {
  int start;
  ReceiverItem({
    this.start = 0,
    required super.fileSystemEntity,
    required super.id,
    required super.fileType,
    required super.fileSize,
    required super.fileName,
    required super.authorId,
    required super.homeDestination,
  });

  Future<void> receive();

  Future<void> cancel();

  Future<void> pause();

  void changeState(IState newState);
}

abstract class UploaderItem extends FileEntityItem {
  UploaderItem({
    required super.fileSystemEntity,
    required super.id,
    required super.fileType,
    required super.fileSize,
    required super.fileName,
    required super.authorId,
    required super.homeDestination,
  });

  int sentBytes = 0;

  Future<void> upload(Future<dynamic> Function(Stream<List<int>> data) future,
      {int start = 0, Function(int)? onDone});
}
