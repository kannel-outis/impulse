import 'package:hive/hive.dart';
import 'package:impulse/services/services.dart';

class HiveManagerImpl extends HiveManager {
  @override
  List<HiveItem> getAllReceiveableItems() {
    final box = Hive.box<HiveItem>(HiveInit.receiveableItemsBox);
    return box.values.toList();
  }

  @override
  List<HiveItem> getAllShareableItems() {
    final box = Hive.box<HiveItem>(HiveInit.shareableItemsBox);
    return box.values.toList();
  }

  @override
  Future<void> saveItem(Item item, String sessionId) async {
    late final Box<HiveItem> box;
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
        homeDestinationAddress: item.homeDestination!.$1,
        homeDestinationPort: item.homeDestination!.$2,
        iState: item.state,
        processedBytes: item.proccessedBytes,
        sessionId: sessionId);

    await box.put(newItem.id, newItem);
  }

  @override
  HiveItem? getReceiveableItemWithKey(String key) {
    final box = Hive.box<HiveItem>(HiveInit.receiveableItemsBox);
    if (!box.containsKey(key)) {
      return null;
    } else {
      return box.get(key);
    }
  }

  @override
  HiveItem? getShareableItemWithKey(String key) {
    final box = Hive.box<HiveItem>(HiveInit.shareableItemsBox);
    if (!box.containsKey(key)) {
      return null;
    } else {
      return box.get(key);
    }
  }
}
