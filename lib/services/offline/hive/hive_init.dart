import 'dart:io';

import 'package:hive/hive.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/services/offline/hive/adapters/hive_item.dart';
import 'package:path_provider/path_provider.dart';

import 'adapters/istate_hive.dart';

class HiveInit {
  static const String receiveableItemsBox = "receiveables";
  static const String shareableItemsBox = "shareables";
  static Future<void> init() async {
    final documentDir = await () async {
      if (Platform.isWindows) {
        return await getApplicationSupportDirectory();
      }
      return await getApplicationDocumentsDirectory();
    }();
    Hive.init(documentDir.path);

    Hive.registerAdapter<HiveItem>(HiveItemAdapter());
    Hive.registerAdapter<IState>(IStateAdapter());

    await Hive.openBox<HiveItem>(receiveableItemsBox);
    await Hive.openBox<HiveItem>(shareableItemsBox);
  }
}
