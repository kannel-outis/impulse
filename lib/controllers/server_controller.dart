import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/assets/assets_images.dart';
import 'package:impulse/models/server_info.dart';
import 'package:impulse/models/user.dart';
import 'package:impulse/services/server_manager.dart';
import 'package:uuid/uuid.dart';

final serverControllerProvider =
    ChangeNotifierProvider<ServerController>((ref) => ServerController());

class ServerController extends ChangeNotifier
    implements ServerManager<ServerInfo> {
  ServerInfo? _serverInfo;
  ServerInfo? get serverInfo {
    print("from : State ${_serverInfo?.user.deviceName}");
    return _serverInfo;
  }

  @override
  List<String> getFiles() {
    return <String>[];
  }

  @override
  List<String> getPaths() {
    return <String>[];
  }

  @override
  Future<ServerInfo> get hostInfo async {
    final bytes = await rootBundle.load(AssetsImage.DEFAULT_DISPLAY_IMAGE);
    final uint8 = bytes.buffer.asUint8List();
    final host = User(
      name: "Host Server",
      id: const Uuid().v4(),
      displayImage: uint8,
      deviceName: Platform.operatingSystem,
      deviceOsVersion: Platform.operatingSystemVersion,
      isHost: true,
    );
    return ServerInfo(
      user: host,
    );
  }

  @override
  Future<ServerInfo> get myServerInfo async {
    final bytes = await rootBundle.load(AssetsImage.DEFAULT_DISPLAY_IMAGE_2);
    final uint8 = bytes.buffer.asUint8List();
    final me = User(
      name: "Client server",
      id: const Uuid().v4(),
      displayImage: uint8,
      deviceName: Platform.operatingSystem,
      deviceOsVersion: Platform.operatingSystemVersion,
      isHost: true,
    );
    return ServerInfo(
      user: me,
    );
  }

  @override
  ServerInfo handlePostResult(Map<String, dynamic> map) {
    _serverInfo = ServerInfo.fromMap(map);
    print("Called from tecno");
    notifyListeners();
    return _serverInfo!;
  }
}
