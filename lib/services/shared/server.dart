import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../services.dart';

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

   HttpServer? _httpServer;
  @override
  int get port => _httpServer?.port ?? 0;

  @override
  HttpServer? get server => _httpServer;

  @override
  InternetAddress get address => _httpServer?.address ?? InternetAddress("0.0.0.0");

  @override
  Future<HttpServer> bind(address, int port) async {
    return _httpServer = await HttpServer.bind(address, port);
  }

  @override
  void listen() {
    _httpServer?.listen(_listener);
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
      print(url);
      httpRequest.response.statusCode = Constants.STATUS_OK;
      httpRequest.response.headers.contentType = ContentType.json;
      final hostInfo = await serverManager.myServerInfo();
      // hostInfo.port = _httpServer.port;
      // hostInfo.ipAddress = _httpServer.address.address;
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
    if (url == _buildUrl("impulse/client_server_info")) {
      print(url);

      ///need to wait for the result to load to memory before closing and decoding
      ///else it may just enter in chunks. the image may make it too large
      final result = await httpRequest.fold<List<int>>(
          [], (previous, element) => previous..addAll(element));
      final response = String.fromCharCodes(result);
      serverManager.handleClientServerNotification(json.decode(response));
      print("object");

      httpRequest.response.statusCode = Constants.STATUS_OK;
      httpRequest.response.headers.contentType = ContentType.json;
      httpRequest.response.write(
        json.encode(
          {"msg": "Successful"},
        ),
      );
      httpRequest.response.close();
    } else if (url == _buildUrl("send")) {
      ///Testing....
      print(httpRequest.headers["filename"]);
      final fileName =
          List.from(httpRequest.headers["filename"] as List<String>).first;
      final fileType =
          List.from(httpRequest.headers["filetype"] as List<String>).first;
      final file =
          File("storage/emulated/0/DCIMM/$fileName.$fileType").openWrite();
      // final result = httpRequest.listen((event) {});
      await for (final data in httpRequest) {
        log(data.length.toString());
        file.add(data);
      }
      await file.close();

      ///TODO: do a response to close the connection
    }
  }

  String _buildUrl(String path) {
    return "http://${address.address}:$port/$path";
  }

  @override
  void close() {
    _httpServer?.close(force: true);
  }
}
