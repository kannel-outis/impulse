import 'package:impulse/services/services.dart';

abstract class HiveManager {
  Future<void> saveItem(Item item);
  List<HiveItem> getAllShareableItems();
  List<HiveItem> getAllReceiveableItems();
  HiveItem? getShareableItemWithKey(String key);
  HiveItem? getReceiveableItemWithKey(String key);
}
