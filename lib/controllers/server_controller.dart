import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:impulse/app/assets/assets_images.dart';
import 'package:impulse/models/user.dart';
import 'package:impulse/services/server_manager.dart';
import 'package:uuid/uuid.dart';

class ServerController extends ChangeNotifier implements ServerManager {
  @override
  List<String> getFiles() {
    return <String>[];
  }

  @override
  List<String> getPaths() {
    return <String>[];
  }

  @override
  Future<User> get hostInfo async {
    final bytes = await rootBundle.load(AssetsImage.DEFAULT_DISPLAY_IMAGE);
    final uint8 = bytes.buffer.asUint8List();
    final host = User(
      name: "Emir Dilony",
      id: const Uuid().v4(),
      displayImage: uint8,
      deviceName: Platform.operatingSystem,
      deviceOsVersion: Platform.operatingSystemVersion,
      isHost: true,
    );
    return host;
  }
}
