import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/app/impulse_exception.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/models/models.dart';
import 'package:impulse/models/server_info.dart';
import 'package:impulse/services/services.dart';

final receiverProvider = ChangeNotifierProvider<ReceiverProvider>(
  (ref) {
    final servermanager = ref.watch(serverControllerProvider);
    final connectedUserState = ref.watch(connectUserStateProvider.notifier);
    return ReceiverProvider(
      servermanager,
      connectedUserState: connectedUserState,
      client: ClientImpl(
        gateWay: MyHttpServer(serverManager: servermanager),
      ),
    );
  },
);

class ReceiverProvider extends ChangeNotifier {
  final Client client;
  final ServerManager _myServer;
  final ConnectedUserState connectedUserState;

  ReceiverProvider(
    this._myServer, {
    required this.client,
    required this.connectedUserState,
  });

  String? _address;
  String? get address => _address;
  int? _port;
  int? get port => _port;
  final List<ServerInfo> _availableHostsServers = [];
  List<ServerInfo> get availableHostServers => _availableHostsServers;
  ServerInfo? _selectedHost;
  ServerInfo? get selectedHost => _selectedHost;

  ///The client can be used as host here because it implements the [Host] abtract class
  ///This function will be called after a successful scan and an available host has be selected
  ///That way we can be sure of two things. 1) a host has been found/selected, 2) The selected host has already occupied the default port ----
  /// --- Thats the green light we need to use the second port.
  Future<AppException?> createServer({
    dynamic address,
    int? port,
    Function(AppException)? onErrorCallback,
  }) async {
    if (client is! ClientHost) {
      const exception = AppException("This client cannot host a server");
      onErrorCallback?.call(exception);
      return exception;
    }
    final result =
        await (client as Host).createServer(address: address, port: port);
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

  void clearAvailableUsers() => _availableHostsServers.clear();

  Future<void> getAvailableUsers() async {
    ///Scan for available ip addresses
    final availableHostIps = await _scan();
    for (final hostIp in availableHostIps) {
      /// for each ip address found, try to make a connection using the default port.
      /// the number of successful connections we make equals the number of available host users or servers
      /// on the network.

      await establishConnection(hostIp: hostIp);
    }
  }

  Future<void> establishConnection(
      {required String hostIp, int? port, bool listReset = false}) async {
    if (listReset) {
      /// we want to be able to have one availableUser when a user uses the QR feature
      /// since only one user can be scanned at once
      clearAvailableUsers();
      notifyListeners();
    }
    final result =
        await client.establishConnectionToHost(address: hostIp, port: port);
    final response = result.map(
      (r) => ServerInfo.fromMap(r["hostServerInfo"]),
    );
    if (response is Right) {
      final user = (response as Right).value as ServerInfo;
      if (!_availableHostsServers
          .map((e) => e.ipAddress)
          .toList()
          .contains(user.ipAddress)) {
        _availableHostsServers.add(user);
      }
    }
    notifyListeners();
  }

  Future<List<String>> _scan() async {
    final list = await client.scan();
    return list;
  }

  void selectHost(ServerInfo selected) {
    if (_availableHostsServers.contains(selected)) {
      _selectedHost = selected;
      notifyListeners();
    }
  }

  ///This method is called from the ui immediately after selecting a host preferably.
  ///It creates the client server and notifies the host by making a post request to the host server
  Future<AppException?> createServerAndNotifyHost(
      {String? ipAddress, int? port}) async {
    if (selectedHost == null && (ipAddress == null || port == null)) {
      return const AppException("No Host has been Selected or found");
    }
    // ignore: unnecessary_this
    final exception = await this.createServer(port: Constants.DEFAULT_PORT_2);
    if (exception != null) {
      return exception;
    } else {
      /// if [selectedHost] is not null that means we have the host ipAddress and port
      /// make a post request to the host with our (the client) info as body
      ///
      /// and in case a qr code is used, ipAddress and port parameters should not be empty
      final myInfo = _myServer.myServerInfo;
      final notifyHost = await client.createServerAndNotifyHost(
        address: ipAddress ?? selectedHost!.ipAddress!,
        port: port ?? selectedHost?.port,
        body: myInfo.toMap(),
      );
      if (notifyHost is Left) {
        final exception = (notifyHost as Left).value as AppException;
        return exception;
      } else if (notifyHost is Right) {
        final result = (notifyHost as Right).value as bool;
        print(result);
        if (result == false) {
          (client as Host).closeServer();
          return const AppException("Request Denied");
        } else {
          /// we have successfully connected to the select host/sender
          connectedUserState.setUserState(_selectedHost);
          return null;
        }
      }
      return null;
    }
  }

  Future<List<NetworkImpulseFileEntity>> getNetworkFiles(
      {String? path, required (String, int) destination}) async {
    final result = <NetworkImpulseFileEntity>[];

    final response = await client.getNetworkFiles(path ?? "root", destination);
    if (response is Left) {
      return [];
    } else {
      final entities = (response as Right).value as List<Map<String, dynamic>>;
      for (var entity in entities) {
        result.add(NetworkImpulseFileEntity.fromMap(entity));
      }
    }
    return result;
  }

  Future<void> addMoreShareablesOnHostServer({
    required Map<String, dynamic> shareableItemMap,
    required (String, int) destination,
  }) async {
    await client.addMoreShareablesOnHostServer(shareableItemMap, destination);
  }

  void disconnect() {
    _availableHostsServers.clear();
    _selectedHost = null;
    (client as Host).closeServer();
  }
}
