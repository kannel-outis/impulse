import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Configurations {
  Configurations._();

  static Configurations? _instance;

  static Configurations get instance {
    if (_instance == null) return _instance = Configurations._();
    return _instance!;
  }

  late final Directory impulseDir;

  Future<void> loadPaths() async {
    ///TODO: Ask for permission
    final applicationDocumentDir = await getApplicationDocumentsDirectory();
    impulseDir = await Directory(
            "${applicationDocumentDir.path}${Platform.pathSeparator}impulse files${Platform.pathSeparator}")
        .create();
  }
}
