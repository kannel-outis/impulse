import 'dart:io';

import '../gateway.dart';

class MyGateWay extends GateWay<ServerSocket, Socket> {
  MyGateWay();
  late final ServerSocket _serverSocket;

  @override
  Future<ServerSocket> bind(address, int port) async {
    _serverSocket = await ServerSocket.bind(address, port);
    return _serverSocket;
  }

  @override
  ServerSocket get server => _serverSocket;

  void _listener(Socket socket) {
    socket.listen((event) {});
  }

  @override
  InternetAddress get address => _serverSocket.address;

  @override
  void close() {}

  @override
  int get port => _serverSocket.port;

  @override
  void listen() {
    _serverSocket.listen(_listener);
  }
}

class MyHttpServer extends GateWay<HttpServer, HttpRequest> {
  MyHttpServer() : super();

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

  @override
  void listen() {
    _httpServer.listen(_listener);
  }

  void _listener(HttpRequest httpRequest) {
    switch (httpRequest.method) {
      case "GET":
        _handleGetRequest(httpRequest);

        break;
      default:
    }
  }

  void _handleGetRequest(HttpRequest httpRequest) {
    final url = httpRequest.requestedUri.toString();
    if (url == "http://${address.address}:$port/impulse/connect") {
      print("object");
      httpRequest.response.write("impulse seen and connected");
      httpRequest.response.close();
    }
  }

  @override
  void close() {
    _httpServer.close(force: true);
  }
}
