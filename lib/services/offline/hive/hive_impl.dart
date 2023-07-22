import 'package:hive/hive.dart';
import 'package:impulse/services/services.dart';

import 'adapters/hive_item.dart';
import 'hive_init.dart';
import 'hive_manager.dart';

class HiveManagerImpl extends HiveManager {
  @override
  List<Item> getAllReceiveableItems() {
    final box = Hive.box<HiveItem>(HiveInit.receiveableItemsBox);
    return box.values.toList();
  }

  @override
  List<Item> getAllShareableItems() {
    final box = Hive.box<HiveItem>(HiveInit.shareableItemsBox);
    return box.values.toList();
  }

  @override
  Future<void> saveItem(Item item) async {
    late final Box box;
    if (item is ReceiveableItem) {
      box = Hive.box<HiveItem>(HiveInit.receiveableItemsBox);
    } else if (item is ShareableItem) {
      box = Hive.box<HiveItem>(HiveInit.shareableItemsBox);
    } else {}

    final newItem = HiveItem(
      fileId: item.id,
      path: item.filePath,
      filename: item.fileName,
      type: item.fileType,
      totalSize: item.fileSize,
      homeUserId: item.authorId,
      homeDestinationAddress: item.homeDestination.$1,
      homeDestinationPort: item.homeDestination.$2,
      iState: item.state,
      processedBytes: item.proccessedBytes,
    );

    await box.put(newItem.id, newItem);
  }
}
