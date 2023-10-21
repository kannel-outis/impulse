import "package:impulse/app/app.dart";
import 'package:impulse/services/online/shared/transfer/file_entity_item.dart';

abstract class ReceiverItem extends FileEntityItem {
  int start;
  ReceiverItem({
    this.start = 0,
    required super.file,
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
