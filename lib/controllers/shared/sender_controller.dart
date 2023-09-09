import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/models/models.dart';
import 'package:impulse/services/services.dart';

import 'server_controller.dart';

final senderProvider = ChangeNotifierProvider<SenderProvider>(
  (ref) {
    final servermanager = ref.read(serverControllerProvider);
    return SenderProvider(
      servermanager,
      host: HostImpl(
        gateWay: MyHttpServer(serverManager: servermanager),
      ),
    );
  },
);

final createServerFuture = FutureProvider((ref) async {
  // throw AppException("Something went wrong");
  return await ref.read(senderProvider).createServer();
});

class SenderProvider extends ChangeNotifier {
  final ServerManager _myServer;
  final Host host;
  SenderProvider(
    this._myServer, {
    required this.host,
  });

  // ServerInfo? _clientServerInfo;
  // ServerInfo? get clientServerInfo {
  //   print("from : State ${_clientServerInfo?.user.deviceName}");
  //   return _clientServerInfo;
  // }

  // ServerController get _myServerController => _myServer as ServerController;

  String? _address;
  String? get ipAddress => _address;
  int? _port;
  int? get port => _port;

  Future<ServerInfo> createServer({
    dynamic address,
    int? port,
    Function(AppException)? onErrorCallback,
  }) async {
    final result = await host.createServer(address: address, port: port);
    if (result is Left) {
      final exception = (result as Left).value as AppException;
      // onErrorCallback?.call(exception);
      throw exception;
    } else {
      final addressAndPort = (result as Right).value as (String, int);
      _myServer.ipAddress = _address = addressAndPort.$1;
      _myServer.port = _port = addressAndPort.$2;
      notifyListeners();
      return _myServer.myServerInfo;
    }
  }

  String serverInfoBarcodeMap() {
    final map = {
      "ip": ipAddress!,
      "port": port!,
    };
    return jsonEncode(map);
  }

  Future<AppException?> shareDownloadableFiles(
      List<Map<String, dynamic>> files, (String, int) destination) async {
    if (files.isEmpty) return const AppException("Nothing has been selected");
    final result = await host.shareDownloadableFiles(files, destination);
    if (result is Left) {
      final exception = (result as Left).value as AppException;
      return exception;
    } else {
      return null;
    }
  }

  // void handleAlertResponse(bool response) {
  //   _myServerController.handleAlertResponse(response);
  // }
}
