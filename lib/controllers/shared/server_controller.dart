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

import 'alert_state_controller.dart';

final serverControllerProvider =
    ChangeNotifierProvider<ServerController>((ref) {
  final alert = ref.read(alertStateNotifier.notifier);
  return ServerController(alert);
});

class ServerController extends ServerManager with ChangeNotifier {
  final AlertState alertState;

  ServerController(this.alertState);

  final alertResponder = Completer<bool>();

  // bool _showAcceptDeclineAlert = false;

  // bool get showAcceptDeclineAlert => _showAcceptDeclineAlert;

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

////TODO: use statenotifier for client server info
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
  Future<bool> handleClientServerNotification(
      Map<String, dynamic> serverMap) async {
    // _showAcceptDeclineAlert = true;
    alertState.updateState(true);
    _clientServerInfo = ServerInfo.fromMap(serverMap);
    final result = await alertResponder.future;
    if (result == false) {
      _clientServerInfo = null;
    }
    // _showAcceptDeclineAlert = false;
    return result;
  }

  void handleAlertResponse(bool response) {
    alertResponder.complete(response);
  }
}
