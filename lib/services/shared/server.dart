import 'dart:convert';
import 'dart:io';

import 'package:impulse/services/server_manager.dart';

import '../gateway.dart';
import '../utils/constants.dart';

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
  final ServerManager serverManager;
  MyHttpServer({required this.serverManager}) : super();

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
      case "POST":
        _handlePostRequest(httpRequest);
      default:
    }
  }

  Future<void> _handleGetRequest(HttpRequest httpRequest) async {
    final url = httpRequest.requestedUri.toString();
    if (url == "http://${address.address}:$port/impulse/connect") {
      print("object");
      httpRequest.response.statusCode = Constants.STATUS_OK;
      httpRequest.response.headers.contentType = ContentType.json;
      final hostInfo = await serverManager.hostInfo;
      hostInfo.port = _httpServer.port;
      hostInfo.ipAddress = _httpServer.address.address;
      httpRequest.response.write(json.encode(
        {
          "hostServerInfo": hostInfo.toMap(),
        },
      ));
      httpRequest.response.close();
    }
  }

  Future<void> _handlePostRequest(HttpRequest httpRequest) async {
    final url = httpRequest.requestedUri.toString();
    if (url == "http://${address.address}:$port/impulse/client_server_info") {
      httpRequest.listen((event) {
        final result = String.fromCharCodes(event);
        print(result);

        httpRequest.response.statusCode = Constants.STATUS_OK;
        httpRequest.response.headers.contentType = ContentType.json;
        httpRequest.response.write(
          json.encode(
            {"msg": "Successful"},
          ),
        );
      });
    }
  }

  @override
  void close() {
    _httpServer.close(force: true);
  }
}
