import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:impulse/app/impulse_exception.dart';
import 'package:impulse/models/server_info.dart';

abstract interface class Host {
  Future<Either<AppException, (String, int)>> createServer(
      {InternetAddress? address, int? port});

  Future<AppException?> shareFile(
      {required String filePath, required ServerInfo destination});
}
