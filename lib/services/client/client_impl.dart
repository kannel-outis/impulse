import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:impulse/app/impulse_exception.dart';

import '../services.dart';

class ClientImpl implements ClientHost {
  final GateWay? gateWay;

  ClientImpl({this.gateWay});
  static const int _port = Constants.DEFAULT_PORT;

  @override
  Future<List<String>> scan() async {
    return await ServicesUtils.scan();
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> establishConnectionToHost(
      {required String address, int? port}) async {
    // if () {
    //   return const Left(
    //     AppException("Cannot make a connection if no host is found"),
    //   );
    // }
    final uri = Uri.parse("http://$address:${port ?? _port}/impulse/connect");
    return await RequestHelper.get(uri);
  }

  @override
  Future<Either<AppException, (String, int)>> createServer(
      {InternetAddress? address, int? port}) {
    if (gateWay == null) const AppException("This receiver is not a host");
    return ServicesUtils.creatServer(
      gateWay: gateWay!,
      address: address,
      port: port,
    );
  }

  @override
  Future<Either<AppException, bool>> createServerAndNotifyHost({
    required String address,
    int? port,
    required Map<String, dynamic> body,
  }) async {
    ///seperate uri builder
    final uri = Uri.parse(
        "http://$address:${port ?? _port}/impulse/client_server_info");
    final s = await RequestHelper.post(uri, body);
    final result =
        s.map((r) => (r["msg"] as String) == "Denied" ? false : true);
    return result;
  }

  @override
  Future<Either<AppException?, Map<String, dynamic>>> shareFile({
    required File file,
    required (String ip, int port) destination,
    Function(int, int)? onProgress,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<List<int>> getFileStreamFromHostServer(
      (String, int) destination, String fileId,
      {Map<String, String>? headers,
      int start = 0,
      required int end,
      Function(int p1, IClient p2)? init}) {
    final url = "http://${destination.$1}:${destination.$2}/download?id=$id";
    return ServicesUtils.getStream(
      url,
      end: end,
      headers: headers,
      init: init,
      start: start,
    );
  }

  @override
  bool get isServerRunning => gateWay != null && gateWay!.isServerRunning;

  @override
  void closeServer() {
    gateWay?.close();
  }

  @override
  Future<Either<AppException?, Map<String, dynamic>>> shareDownloadableFiles(
      List<Map<String, dynamic>> files, (String, int) destination) {
    // TODO: implement shareDownloadableFiles
    throw UnimplementedError();
  }
}
