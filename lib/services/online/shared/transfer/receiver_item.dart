import "package:impulse/app/app.dart";

import "item.dart";

abstract class ReceiverItem extends Item {
  int start;
  ReceiverItem({
    required super.authorId,
    required super.file,
    required super.fileName,
    required super.fileSize,
    required super.fileType,
    super.homeDestination,
    required this.start,
    required super.id,
  });
  Future<void> receive();

  Future<void> cancel();

  Future<void> pause();

  void changeState(IState newState);
}
