import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:impulse/app/app.dart';

import '../../../services.dart';

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
      final hostInfo = serverManager.myServerInfo;
      // hostInfo.port = _httpServer.port;
      // hostInfo.ipAddress = _httpServer.address.address;
      httpRequest.response.write(
        json.encode(
          {
            "hostServerInfo": hostInfo.toMap(),
          },
        ),
      );
      httpRequest.response.close();
    } else if (url.contains("http://${address.address}:$port/download")) {
      if (httpRequest.requestedUri.queryParameters.containsKey("file")) {
        final file =
            File(httpRequest.requestedUri.queryParameters["file"] as String);
        if (!await file.exists()) {
          httpRequest.response.statusCode = 404;
          httpRequest.response.write(
            json.encode(
              {
                "msg": "File not Found available",
              },
            ),
          );
          httpRequest.response.close();
          return;
        } else {
          final fileStream = file.openRead();
          await httpRequest.response.addStream(fileStream);
          httpRequest.response.close();
          return;
        }
      }

      ///get the id of the file from the url query parameter
      final fileId = httpRequest.requestedUri.queryParameters["id"];

      String rangeHeader = httpRequest.headers.value(HttpHeaders.rangeHeader)!;
      final start = int.parse(rangeHeader.split('=')[1].split('-')[0]);

      ///Check if the id exists in the shareable files list
      ///if the file was indeed shared, it should have an id in the list
      final items = serverManager
          .getSelectedItems()
          .where((element) => element.id == fileId);
      if (fileId == null || items.isEmpty) {
        ///if this file cant be found, write a response and close connection
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

      ///if fpund retreive the item with the id
      final item = items.single;

      ///Check if the file with that id exists on the device,
      ///if it does proceed to open the file and make it downloadable
      if (await item.file.exists()) {
        item.startTime = DateTime.now();
        httpRequest.response
          ..headers.set("Content-Type", item.mime ?? "application/octat-stream")
          ..headers
              .set("Content-Disposition", "attachment; filename=${item.name}")
          ..headers.set("Content-Length", "${item.file.lengthSync() - start}");

        final hiveItem = await serverManager.getHiveItemForShareable(item);
        void listener(int received, int totalSize, File? file, String? reason,
            IState state) {
          hiveItem.iState = state;
          hiveItem.processedBytes = received;
          hiveItem.save();
          // print("${state} ::::::::::::::::::");
        }

        ///add listener that works the hive operation
        item.addListener(listener);

        ///This should be start
        int bytesDownloadedByClient = start;
        final response = httpRequest.response;
        final fileStream = item.file.openRead(start);
        await response.addStream(fileStream.map((event) {
          bytesDownloadedByClient += event.length;

          // final percentage =
          //     (bytesDownloadedByClient / item.file.lengthSync()) * 100;
          // log("${item.fileName}: $percentage");
          // item.onProgressCallback?.call(
          // bytesDownloadedByClient,
          // item.file.lengthSync(),
          // IState.inProgress,
          // );

          (item as ShareableItem).updateProgress(
            bytesDownloadedByClient,
            item.file.lengthSync(),
            IState.inProgress,
          );
          return event;
        }));
        // await httpRequest.response.addStream(item.file.openRead());

        // item.onProgressCallback?.call(
        //   bytesDownloadedByClient,
        //   item.file.lengthSync(),
        //   IState.completed,
        // );

        (item as ShareableItem).updateProgress(
          bytesDownloadedByClient,
          item.file.lengthSync(),
          bytesDownloadedByClient != item.file.lengthSync()
              ? IState.paused
              : IState.completed,
        );
        // await response.flush();
        httpRequest.response.close();

        ///remove listener
        item.removeListener(listener);
        item.startTime = null;
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
        // log(el.toString());
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
    } else if (url == _buildUrl("cancel")) {
      final result = await httpRequest.fold<List<int>>(
          [], (previous, element) => previous..addAll(element));
      final bodyEncoded = String.fromCharCodes(result);
      final fileId = jsonDecode(bodyEncoded)["fileId"] as String;
      serverManager.removeCanceledItem(fileId);
      httpRequest.response.statusCode = Constants.STATUS_OK;
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
