// ignore_for_file: unnecessary_getters_setters

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

class ServerController extends ServerManager with ChangeNotifier {
  String? _ipAddress;
  @override
  String? get ipAddress => _ipAddress;
  @override
  set ipAddress(String? ip) {
    _ipAddress = ip;
  }

  int? _port;
  @override
  int? get port => _port;
  @override
  set port(int? port) {
    _port = port;
  }

  ServerInfo? _clientServerInfo;
  @override
  ServerInfo? get clientServerInfo {
    print("from : State ${_clientServerInfo?.user.deviceName}");
    return _clientServerInfo;
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
  Future<ServerInfo> myServerInfo() async {
    final bytes = await rootBundle.load(AssetsImage.DEFAULT_DISPLAY_IMAGE_2);
    final uint8 = bytes.buffer.asUint8List();
    final me = User(
      name: "Client server",
      id: const Uuid().v4(),
      displayImage: uint8,
      deviceName: Platform.operatingSystem,
      deviceOsVersion: Platform.operatingSystemVersion,
      isHost: true,
      ipAddress: _ipAddress,
    );
    return ServerInfo(
      user: me,
      ipAddress: _ipAddress,
      port: _port,
    );
  }

  @override
  handleClientServerNotification(Map<String, dynamic> serverMap) {
    _clientServerInfo = ServerInfo.fromMap(serverMap);
    print("Called from tecno");
    notifyListeners();
    return _clientServerInfo;
  }
}
