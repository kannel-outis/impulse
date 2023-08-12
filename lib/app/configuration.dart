import 'dart:io';

import 'package:impulse/models/models.dart';
import 'package:impulse/services/offline/hive/hive_init.dart';
import 'package:impulse/services/services.dart';
import 'package:impulse_utils/impulse_utils.dart';
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

  FileManager get fileManager => FileManager.instance;

  ImpulseUtils get impulseUtils => ImpulseUtils();

  Future<void> _loadPaths() async {
    final applicationDocumentDir = await getApplicationDocumentsDirectory();
    if (Platform.isAndroid) {
      await fileManager.getRootPaths(true);
      impulseDir = await Directory(
              "${fileManager.rootPath.where((element) => element.contains("emulated")).toList().first}${Platform.pathSeparator}impulse files${Platform.pathSeparator}")
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

  ImpulseSharedPref get localPref => ImpulseSharedPrefImpl.instance;

  User? _user;

  //for first start
  User? get user =>
      _user ??
      (ImpulseSharedPrefImpl.instance.getUserInfo() == null
          ? null
          : User.fromMap(
              ImpulseSharedPrefImpl.instance.getUserInfo()!,
            ));

  void loadUser() {
    _user = ImpulseSharedPrefImpl.instance.getUserInfo() == null
        ? null
        : User.fromMap(ImpulseSharedPrefImpl.instance.getUserInfo()!);
  }

  Future<void> loadAllInit() async {
    await ImpulseSharedPrefImpl.instance.loadInstance();
    await _loadHiveInit();
    await _loadPaths();
    loadUser();
    composition = await AssetLottie("assets/lottie/waiting.json").load();
  }
}
