import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:impulse/app/impulse_exception.dart';

import '../../services.dart';

class HostImpl extends Client implements Host {
  // final Connection connection;
  final GateWay gateWay;

  HostImpl({required this.gateWay});
  @override
  Future<Either<AppException, (String, int)>> createServer(
      {address, port}) async {
    return ServicesUtils.creatServer(
      gateWay: gateWay,
      address: address,
      port: port,
    );
  }

  // @override
  // Future<List<String>> scan() async {
  //   return await ServicesUtils.scan();
  // }

  @override
  Future<Either<AppException, bool>> createServerAndNotifyHost({
    String? address,
    int? port,
    required Map<String, dynamic> serverInfo,
    required Map<String, dynamic> sessionInfo,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<AppException?, Map<String, dynamic>>> shareFile({
    required File file,
    required (String ip, int port) destination,
    Function(int, int)? onProgress,
  }) async {
    // try {
    //   final uri = "http://${destination.$1}:${destination.$2}/send";
    //   if (!file.existsSync()) {
    //     throw const AppException("File does not exist");
    //   }
    //   // final stream = file.openRead();
    //   final dio = Dio();
    //   final response = await dio.post<Map<String, dynamic>>(
    //     uri,
    //     data: file.openRead(),
    //     options: Options(
    //       contentType: ContentType.binary.value,
    //       headers: {"filename": "emir", "filetype": "mp4"},
    //     ),
    //     onSendProgress: (count, total) {
    //       log((count / total).toString());
    //       onProgress?.call(count, total);
    //     },
    //     onReceiveProgress: (e, r) {
    //       log("Receiving: $e/$r");
    //     },
    //   );

    //   return Right(jsonDecode(response.data.toString()));
    // } catch (e) {
    //   print(e.toString());
    //   return Left(AppException(e.toString()));
    // }
    throw UnimplementedError();
  }

  @override
  bool get isServerRunning => gateWay.isServerRunning;

  @override
  void closeServer() {
    gateWay.close();
  }

  @override
  Stream<List<int>> getFileStreamFromHostServer(
      (String, int) destination, String fileId,
      {Map<String, String>? headers,
      int start = 0,
      required int end,
      Function(int p1, IClient p2)? init}) {
    final url =
        "http://${destination.$1}:${destination.$2}/${ServicesUtils.serverRoutes.download}?id=$id";
    return ServicesUtils.getStream(
      url,
      end: end,
      headers: headers,
      init: init,
      start: start,
    );
  }

  @override
  Future<Either<AppException?, Map<String, dynamic>>> shareDownloadableFiles(
      List<Map<String, dynamic>> files, (String, int) destination) {
    final url = Uri.parse(
        "http://${destination.$1}:${destination.$2}/${ServicesUtils.serverRoutes.shareables}");
    final body = {
      "files": files,
    };
    return RequestHelper.post(url, body);
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
  Future<Either<AppException?, List<Map<String, dynamic>>>> getNetworkFiles(
      String path, (String, int) destination) {
    final url =
        "http://${destination.$1}:${destination.$2}/${ServicesUtils.serverRoutes.download}?folder=$path";

    return RequestHelper.getList(Uri.parse(url));
  }

  @override
  Future<Either<AppException?, Map<String, dynamic>>>
      addMoreShareablesOnHostServer(
          Map<String, dynamic> shareableItemMap, (String, int) destination) {
    final url = Uri.parse(
        "http://${destination.$1}:${destination.$2}/${ServicesUtils.serverRoutes.shareables_more}");

    return RequestHelper.post(
      url,
      shareableItemMap,
    );
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> continuePreviousDownloads(
      (String, int) destination) {
    final url = Uri.parse(
        "http://${destination.$1}:${destination.$2}/${ServicesUtils.serverRoutes.continue_previous}");
    final body = {"continue": true};
    return RequestHelper.post(url, body);
  }
}
