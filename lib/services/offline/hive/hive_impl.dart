import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/services/services.dart';

class HiveManagerImpl extends HiveManager {
  HiveManagerImpl._();

  static HiveManager? _instance;

  static HiveManager get instance {
    _instance ??= HiveManagerImpl._();
    return _instance!;
  }

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
    try {
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
        sessionId: sessionId,
      );
      if (box.containsKey(newItem.id)) {
        return;
      }

      await box.put(newItem.id, newItem);
    } catch (e, s) {
      log(e.toString(), stackTrace: s);
    }
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

    return box.get(key);
  }

  @override
  Future<HiveSession> saveSession(String userId, String sessionId) async {
    final sessionBox = Hive.box<HiveSession>(HiveInit.session);
    if (sessionBox.containsKey(userId)) {
      return sessionBox.get(userId)!;
    } else {
      final hiveUser = HiveSession(
        userId: userId,
        previousSessionId: sessionId,
        lastSessionDateTime: DateTime.now().toString(),
      );
      final _ = await sessionBox.put(userId, hiveUser);
      return hiveUser;
    }
  }

  @override
  void removeItemWithKey(String key) {
    final shareableBox = Hive.box<HiveItem>(HiveInit.shareableItemsBox);
    final receivableBox = Hive.box<HiveItem>(HiveInit.receiveableItemsBox);
    if (shareableBox.containsKey(key)) {
      shareableBox.delete(key);
    } else if (receivableBox.containsKey(key)) {
      receivableBox.delete(key);
    }
  }

  @override
  Future<void> updateUserSession(HiveSession session) async {
    final sessionBox = Hive.box<HiveSession>(HiveInit.session);
    if (sessionBox.containsKey(session.userId)) {
      sessionBox.put(session.userId, session);
    } else {
      throw const AppException("User does not exist");
    }
  }
}
