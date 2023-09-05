import 'package:impulse/services/services.dart';

abstract class HiveManager {
  Future<void> saveItem(Item item, String sessionId);
  Future<HiveSession> saveSession(String userId, String sessionId);
  Future<void> updateUserSession(HiveSession session);
  List<HiveItem> getAllShareableItems();
  List<HiveItem> getAllReceiveableItems();
  // List<HiveItem> getAllReceiveableItemsFromSession(String sessionId);
  // List<HiveItem> getAllShareableItemsFromSession(String sessionId);
  HiveItem? getShareableItemWithKey(String key);
  HiveItem? getReceiveableItemWithKey(String key);
  void removeItemWithKey(String key);
}
