import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:impulse/app/impulse_exception.dart';

abstract interface class Host {
  Future<Either<AppException, (String, int)>> createServer(
      {InternetAddress? address, int? port});

  void closeServer();

  Future<Either<AppException?, Map<String, dynamic>>> shareFile({
    required File file,
    required (String, int) destination,
    Function(int, int)? onProgress,
  });
  Future<Either<AppException?, Map<String, dynamic>>> shareDownloadableFiles(
      List<Map<String, dynamic>> files, (String, int) destination);
  bool get isServerRunning;
}
