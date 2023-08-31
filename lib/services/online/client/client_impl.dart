import 'dart:io';

import 'package:dartz/dartz.dart' as dartz;
import 'package:impulse/app/impulse_exception.dart';

import '../../services.dart';

class ClientImpl implements ClientHost {
  final GateWay? gateWay;

  ClientImpl({this.gateWay});
  static const int _port = Constants.DEFAULT_PORT;

  @override
  Future<List<String>> scan() async {
    return await ServicesUtils.scan();
  }

  @override
  Future<dartz.Either<AppException, Map<String, dynamic>>>
      establishConnectionToHost({required String address, int? port}) async {
    // if () {
    //   return const Left(
    //     AppException("Cannot make a connection if no host is found"),
    //   );
    // }
    final uri = Uri.parse(
        "http://$address:${port ?? _port}/${ServicesUtils.serverRoutes.connect}");
    return await RequestHelper.get(uri);
  }

  @override
  Future<dartz.Either<AppException, (String, int)>> createServer(
      {InternetAddress? address, int? port}) {
    if (gateWay == null) const AppException("This receiver is not a host");
    return ServicesUtils.creatServer(
      gateWay: gateWay!,
      address: address,
      port: port,
    );
  }

  @override
  Future<dartz.Either<AppException, bool>> createServerAndNotifyHost({
    required String address,
    int? port,
    required Map<String, dynamic> serverInfo,
    required Map<String, dynamic> sessionInfo,
  }) async {
    ///seperate uri builder
    final uri = Uri.parse(
        "http://$address:${port ?? _port}/${ServicesUtils.serverRoutes.client_server_info}");
    final body = {
      "serverInfo": serverInfo,
      "sessionInfo": sessionInfo,
    };
    final s = await RequestHelper.post(uri, body);
    final result =
        s.map((r) => (r["msg"] as String) == "Denied" ? false : true);
    return result;
  }

  @override
  Future<dartz.Either<AppException?, Map<String, dynamic>>> shareFile({
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
    final url =
        "http://${destination.$1}:${destination.$2}/${ServicesUtils.serverRoutes.download}?id=$fileId";
    // return Stream.empty();
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
  Future<dartz.Either<AppException?, Map<String, dynamic>>>
      shareDownloadableFiles(
          List<Map<String, dynamic>> files, (String, int) destination) {
    // TODO: implement shareDownloadableFiles
    throw UnimplementedError();
  }

  @override
  Future<void> cancelItem((String, int) destination, String fileId) {
    final url = Uri.parse(
        "http://${destination.$1}:${destination.$2}/${ServicesUtils.serverRoutes.cancel}");
    final body = {
      "fileId": fileId,
    };
    return RequestHelper.post(
      url,
      body,
    );
  }

  @override
  Future<dartz.Either<AppException?, List<Map<String, dynamic>>>>
      getNetworkFiles(String path, (String, int) destination) {
    final url =
        "http://${destination.$1}:${destination.$2}/${ServicesUtils.serverRoutes.download}?folder=$path";

    return RequestHelper.getList(Uri.parse(url));
  }

  @override
  Future<dartz.Either<AppException?, Map<String, dynamic>>>
      addMoreShareablesOnHostServer(
          Map<String, dynamic> shareableItemMap, (String, int) destination) {
    final url = Uri.parse(
        "http://${destination.$1}:${destination.$2}/${ServicesUtils.serverRoutes.shareables_more}");

    return RequestHelper.post(
      url,
      shareableItemMap,
    );
  }
}
