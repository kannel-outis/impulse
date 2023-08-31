import 'package:impulse/services/services.dart';


abstract class HiveManager {
  Future<void> saveItem(Item item, String sessionId);
  Future<HiveUser> saveSession(String userId, String sessionId);
  List<HiveItem> getAllShareableItems();
  List<HiveItem> getAllReceiveableItems();
  HiveItem? getShareableItemWithKey(String key);
  HiveItem? getReceiveableItemWithKey(String key);
}
