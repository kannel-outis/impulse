import 'package:impulse/services/online/shared/transfer/file_entity_item.dart';
import 'package:impulse/services/services.dart';

mixin MultipleItemsStart<T extends Item> on FileEntityItem {
  List<T> get files;
  ({int index, int fileProccessed}) startPosition(int start) {
    final items = files;
    late final int index;
    final folderProccessed = fileSize - start;
    int fileProcessed = folderProccessed;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (folderProccessed < item.fileSize) {
        index = i;
        break;
      } else {
        fileProcessed = fileProcessed - item.fileSize;
      }
    }
    return (index: index, fileProccessed: fileProcessed);
  }
}
