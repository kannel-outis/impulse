import 'dart:io';

import 'package:impulse/models/server.dart';

import 'user.dart';

class Connection {
  final Server server;
  final List<User> usersOnNetwork;
  final String hostId;

  Connection({
    required this.server,
    required this.usersOnNetwork,
    required this.hostId,
  });
}

class MyServer extends Server<ServerSocket, Socket> {
  MyServer() : super(_listener);
  late final ServerSocket _serverSocket;

  @override
  Future<ServerSocket> bind(address, int port) async {
    _serverSocket = await ServerSocket.bind(address, port);
    return _serverSocket;
  }

  @override
  ServerSocket get gateWay => _serverSocket;

  static void _listener(Socket socket) {}
}
