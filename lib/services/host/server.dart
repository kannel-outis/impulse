import 'dart:io';

import '../gateway.dart';

class MyGateWay extends GateWay<ServerSocket, Socket> {
  MyGateWay() : super(_listener);
  late final ServerSocket _serverSocket;

  @override
  Future<ServerSocket> bind(address, int port) async {
    _serverSocket = await ServerSocket.bind(address, port);
    return _serverSocket;
  }

  @override
  ServerSocket get server => _serverSocket;

  static void _listener(Socket socket) {
    socket.listen((event) {});
  }

  @override
  InternetAddress get address => _serverSocket.address;

  @override
  void close() {}

  @override
  int get port => _serverSocket.port;
}

class MyHttpServer extends GateWay<HttpServer, HttpRequest> {
  MyHttpServer() : super(_listener);

  late final HttpServer _httpServer;
  @override
  int get port => _httpServer.port;

  @override
  HttpServer? get server => _httpServer;

  @override
  InternetAddress get address => _httpServer.address;

  @override
  Future<HttpServer> bind(address, int port) async {
    return _httpServer = await HttpServer.bind(address, port);
  }

  static void _listener(HttpRequest httpRequest) {}

  @override
  void close() {
    _httpServer.close(force: true);
  }
}
