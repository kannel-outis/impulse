// ignore_for_file: unnecessary_getters_setters

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/assets/assets_images.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/models/server_info.dart';
import 'package:impulse/models/user.dart';
import 'package:impulse/services/services.dart';
import 'package:uuid/uuid.dart';

final serverControllerProvider =
    ChangeNotifierProvider<ServerController>((ref) {
  final alert = ref.watch(alertStateNotifier.notifier);
  final connectedUser = ref.watch(connectUserStateProvider.notifier);
  return ServerController(
    alertState: alert,
    connectedUserState: connectedUser,
  );
});

class ServerController extends ServerManager with ChangeNotifier {
  final AlertState alertState;
  final ConnectedUserState connectedUserState;

  ServerController({
    required this.alertState,
    required this.connectedUserState,
  });

  Completer<bool> alertResponder = Completer<bool>();
  StreamController<Map<String, dynamic>> _receivableStreamController =
      StreamController<Map<String, dynamic>>();
  Timer? _timer;
  List<Item> _items = [];

  /////
  /// The Senders/Hosts ip address and port that needs to be set after server creation
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

  ///This is called everytime we select an file or item
  ///cleed from [SelectedItems] provider
  @override
  void setSelectedItems(List<Item> items) {
    _items = items;
  }

  @override
  List<Item> getSelectedItems() {
    return _items;
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
    // ignore: todo
    //TODO: remove alertstate entirely and use connectedUserState.setUserState(serverInfo, fling: true)
    // to show alert instead
    alertState.updateState(true);
    final serverInfo = ServerInfo.fromMap(serverMap);
    connectedUserState.setUserState(serverInfo, fling: true);

    //// so that users wont take too long
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      handleAlertResponse(false);
    });

    ////
    final result = await alertResponder.future;
    if (result == false) {
      connectedUserState.setUserState(null);
    } else {
      connectedUserState.setUserState(serverInfo);
    }
    // _showAcceptDeclineAlert = false;
    return result;
  }

  void handleAlertResponse(bool response) async {
    alertResponder.complete(response);
    alertState.updateState(false);
    _timer?.cancel();
    alertResponder = Completer<bool>();
  }

  void reset() {
    _receivableStreamController = StreamController<Map<String, dynamic>>();
  }

  @override
  StreamController<Map<String, dynamic>> get receivablesStreamController =>
      _receivableStreamController;
}
