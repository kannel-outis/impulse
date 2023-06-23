import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse_utils/impulse_utils.dart';

final fileManagerProvider =
    ChangeNotifierProvider((ref) => FileManagerController());

class FileManagerController extends ChangeNotifier {
  List<ImpulseFileEntity> goToPath([ImpulseFileEntity? dir]) {
    /// if no directory is provided, it goes directly to internal storage
    return FileManager.instance.getFileInDir(dir);
  }
}
