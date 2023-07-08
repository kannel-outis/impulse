import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/impulse_exception.dart';
import 'package:impulse/controllers/shared/server_controller.dart';
import 'package:impulse/models/server_info.dart';
import 'package:impulse/services/services.dart';

final senderProvider = ChangeNotifierProvider<SenderProvider>(
  (ref) {
    final servermanager = ref.watch(serverControllerProvider);
    return SenderProvider(
      servermanager,
      host: HostImpl(
        gateWay: MyHttpServer(serverManager: servermanager),
      ),
    );
  },
);

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

  ServerController get _myServerController => _myServer as ServerController;

  String? _address;
  String? get ipAddress => _address;
  int? _port;
  int? get port => _port;

  Future<AppException?> createServer({
    dynamic address,
    int? port,
    Function(AppException)? onErrorCallback,
  }) async {
    final result = await host.createServer(address: address, port: port);
    if (result is Left) {
      final exception = (result as Left).value as AppException;
      onErrorCallback?.call(exception);
      return exception;
    } else {
      final addressAndPort = (result as Right).value as (String, int);
      _myServer.ipAddress = _address = addressAndPort.$1;
      _myServer.port = _port = addressAndPort.$2;
      notifyListeners();
      return null;
    }
  }

  void handleAlertResponse(bool response) {
    _myServerController.handleAlertResponse(response);
  }
}
