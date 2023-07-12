import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:impulse/app/impulse_exception.dart';

import '../services.dart';

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
  Future<Either<AppException, bool>> createServerAndNotifyHost(
      {String? address, int? port, required Map<String, dynamic> body}) {
    throw UnimplementedError();
  }

  ///TODO: shareFiles -  route to share the list of files the receiver will download
  @override
  Future<Either<AppException?, Map<String, dynamic>>> shareFile({
    required File file,
    required (String ip, int port) destination,
    Function(int, int)? onProgress,
  }) async {
    try {
      final uri = "http://${destination.$1}:${destination.$2}/send";
      if (!file.existsSync()) {
        throw const AppException("File does not exist");
      }
      // final stream = file.openRead();
      final dio = Dio();
      final response = await dio.post<Map<String, dynamic>>(
        uri,
        data: file.openRead(),
        options: Options(
          contentType: ContentType.binary.value,
          headers: {"filename": "emir", "filetype": "mp4"},
        ),
        onSendProgress: (count, total) {
          log((count / total).toString());
          onProgress?.call(count, total);
        },
        onReceiveProgress: (e, r) {
          log("Receiving: $e/$r");
        },
      );

      return Right(jsonDecode(response.data.toString()));
    } catch (e) {
      print(e.toString());
      return Left(AppException(e.toString()));
    }
  }

  @override
  bool get isServerRunning => gateWay.isServerRunning;

  @override
  void closeServer() {
    gateWay.close();
  }
}
