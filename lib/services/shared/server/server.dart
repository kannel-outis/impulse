import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../../services.dart';

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
  InternetAddress get address =>
      _httpServer?.address ?? InternetAddress("0.0.0.0");

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
    } else if (url.contains("http://${address.address}:$port/download")) {
      final fileId = httpRequest.requestedUri.queryParameters["id"];
      final items = serverManager
          .getSelectedItems()
          .where((element) => element.id == fileId);
      if (fileId == null || items.isEmpty) {
        httpRequest.response.write(
          json.encode(
            {
              "msg": items.isEmpty
                  ? "File id: $fileId not Found"
                  : "File not available",
            },
          ),
        );
        httpRequest.response.close();
        return;
      }
      final item = items.single;

      // final file = File(
      //     "C:/Users/emirb/Downloads/Guardians of the Galaxy Vol. 3 (2023) (NetNaija.com).mkv");
      // final file2 = File("C:/Users/emirb/Downloads/placeholder.png");
      // final file3 =
      //     File("/storage/emulated/0/Movies/ScreenRecord/20220304081125.mp4");
      // final rangeHeader = httpRequest.headers.value(HttpHeaders.rangeHeader);

      if (await item.file.exists()) {
        httpRequest.response
          ..headers.set("Content-Type", item.mime ?? "application/octat-stream")
          ..headers
              .set("Content-Disposition", "attachment; filename=${item.name}")
          ..headers.set("Content-Length", "${item.file.lengthSync()}");
        await httpRequest.response.addStream(item.file.openRead());
        httpRequest.response.close();
        // print("Done");
      } else {
        httpRequest.response.write(
          json.encode(
            {
              "msg": "Something Went Wrong",
            },
          ),
        );
        httpRequest.response.close();
      }
    }
  }

  Future<void> _handlePostRequest(HttpRequest httpRequest) async {
    final url = httpRequest.requestedUri.toString();
    if (url == _buildUrl("impulse/client_server_info")) {
      ///need to wait for the result to load to memory before closing and decoding
      ///else it may just enter in chunks. the image may make it too large
      final result = await httpRequest.fold<List<int>>(
          [], (previous, element) => previous..addAll(element));
      final bodyEncoded = String.fromCharCodes(result);
      final accepted = await serverManager
          .handleClientServerNotification(json.decode(bodyEncoded));

      httpRequest.response.statusCode = Constants.STATUS_OK;
      httpRequest.response.headers.contentType = ContentType.json;
      httpRequest.response.write(
        json.encode(
          {"msg": accepted ? "Successful" : "Denied"},
        ),
      );
      log(accepted.toString());
      httpRequest.response.close();
    } else if (url == _buildUrl("send")) {
      ///Testing....
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

      // ignore: todo
      // /TODO: do a response to close the connection
      httpRequest.response.close();
    } else if (url == _buildUrl("sharables")) {
      final result = await httpRequest.fold<List<int>>(
          [], (previous, element) => previous..addAll(element));
      final bodyEncoded = String.fromCharCodes(result);
      // print(bodyEncoded);
      final List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.from(json.decode(bodyEncoded)["files"]);
      for (var el in list) {
        log(el.toString());
        serverManager.receivablesStreamController.add(el);
      }

      httpRequest.response.statusCode = Constants.STATUS_OK;
      httpRequest.response.headers.contentType = ContentType.json;
      httpRequest.response.write(
        json.encode(
          {"msg": "Reveived"},
        ),
      );
      httpRequest.response.close();
    }
  }

  String _buildUrl(String path) {
    return "http://${address.address}:$port/$path";
  }

  @override
  void close() {
    _httpServer?.close(force: true);
    // ignore: avoid_print
    print("Server Close: ${serverManager.ipAddress}:${serverManager.port}");
    serverManager.port = null;
    serverManager.ipAddress = null;
  }
}
