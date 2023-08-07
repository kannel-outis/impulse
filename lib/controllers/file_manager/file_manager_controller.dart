import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse_utils/impulse_utils.dart';

final fileManagerProvider =
    ChangeNotifierProvider((ref) => FileManagerController());

class FileManagerController extends ChangeNotifier {
  List<ImpulseFileEntity> goToPath([ImpulseFileEntity? dir]) {
    /// *if no directory is provided, it goes directly to internal storage
    return FileManager.instance.getFileInDir(dir);
  }

  Future<List<ImpulseFileEntity>> goToPathAsync(
      [ImpulseFileEntity? _dir]) async {
    // late final ImpulseFileEntity dir;
    // if (_dir == null) {
    //   final d = goToPath(
    //       ImpulseDirectory(directory: Directory("/storage/4EF2-EB5A/")));
    //   for (var element in d) {
    //     print(element.name);
    //   }
    // }
    // } else {}
    return await FileManager.instance.getFileInDirAsync(_dir);
  }
}
