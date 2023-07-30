import 'dart:io';

import 'package:impulse/services/offline/hive/hive_init.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';

class Configurations {
  Configurations._();

  static Configurations? _instance;

  static Configurations get instance {
    if (_instance == null) return _instance = Configurations._();
    return _instance!;
  }

  late final Directory impulseDir;

  Future<void> _loadPaths() async {
    ///TODO: Ask for permission
    final applicationDocumentDir = await getApplicationDocumentsDirectory();
    if (Platform.isAndroid) {
      impulseDir = await Directory(
              "${Platform.pathSeparator}storage${Platform.pathSeparator}emulated${Platform.pathSeparator}0${Platform.pathSeparator}impulse files${Platform.pathSeparator}")
          .create();
      return;
    }
    impulseDir = await Directory(
            "${applicationDocumentDir.path}${Platform.pathSeparator}impulse files${Platform.pathSeparator}")
        .create();
  }

  Future<void> _loadHiveInit() async {
    await HiveInit.init();
  }

  late final LottieComposition composition;

  Future<void> loadAllInit() async {
    await Future.value([
      _loadHiveInit(),
      _loadPaths(),
    ]);
    composition = await AssetLottie("assets/lottie/waiting.json").load();
  }
}
