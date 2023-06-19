import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/impulse_exception.dart';
import 'package:impulse/controllers/shared/server_controller.dart';
import 'package:impulse/services/services.dart';

final hostProvider = ChangeNotifierProvider<HostProvider>(
  (ref) {
    final servermanager = ref.watch(serverControllerProvider);
    return HostProvider(
      myServer: servermanager,
      host: Sender(
        gateWay: MyHttpServer(serverManager: servermanager),
      ),
    );
  },
);

class HostProvider extends ChangeNotifier {
  final ServerManager myServer;
  final Host host;
  HostProvider({
    required this.host,
    required this.myServer,
  });

  // ServerInfo? _clientServerInfo;
  // ServerInfo? get clientServerInfo {
  //   print("from : State ${_clientServerInfo?.user.deviceName}");
  //   return _clientServerInfo;
  // }

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
      myServer.ipAddress = _address = addressAndPort.$1;
      myServer.port = _port = addressAndPort.$2;
      notifyListeners();
      return null;
    }
  }

  // @override
  // Future<ServerInfo> get myServerInfo async {
  //   final bytes = await rootBundle.load(AssetsImage.DEFAULT_DISPLAY_IMAGE);
  //   final uint8 = bytes.buffer.asUint8List();
  //   final me = User(
  //     name: Platform.localHostname,
  //     id: const Uuid().v4(),
  //     displayImage: uint8,
  //     deviceName: Platform.operatingSystem,
  //     deviceOsVersion: Platform.operatingSystemVersion,
  //     isHost: true,
  //     ipAddress: _address!,
  //   );
  //   return ServerInfo(
  //     user: me,
  //     ipAddress: _address!,
  //     port: _port!,
  //   );
  // }

  // @override
  // handleClientServerNotification(Map<String, dynamic> serverMap) {
  //   _clientServerInfo = ServerInfo.fromMap(serverMap);
  //   print("Called from tecno");
  //   notifyListeners();
  //   return _clientServerInfo;
  // }
}
