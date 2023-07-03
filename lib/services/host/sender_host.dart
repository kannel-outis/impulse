import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:impulse/app/impulse_exception.dart';
import 'package:impulse/models/server_info.dart';

import '../services.dart';

class Sender extends Client implements Host {
  // final Connection connection;
  final GateWay gateWay;

  Sender({required this.gateWay});
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
  Future<Either<AppException, Map<String, dynamic>>> makePostRequest(
      {String? address, int? port, required Map<String, dynamic> body}) {
    throw UnimplementedError();
  }

  @override
  Future<AppException?> shareFile(
      {required String filePath, required ServerInfo destination}) async {
    try {
      final uri = "http://${destination.ipAddress}:${destination.port}/send";
      final file = File(filePath);
      if (!file.existsSync()) {
        throw const AppException("File does not exist");
      }
      // final stream = file.openRead();
      final dio = Dio();
      await dio.post(
        uri,
        data: file.openRead(),
        options: Options(
          contentType: ContentType.binary.value,
          headers: {"filename": "emir", "filetype": "mp4"},
        ),
        onSendProgress: (count, total) {
          log((count / total).toString());
        },
        onReceiveProgress: (e, r) {
          log("Receiving: $e/$r");
        },
      );
      return null;
    } catch (e) {
      print(e.toString());
      return AppException(e.toString());
    }
  }

  @override
  bool get isServerRunning => gateWay.isServerRunning;
}
