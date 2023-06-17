import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:impulse/app/impulse_exception.dart';

abstract interface class Host {
  Future<Either<AppException, (String, int)>> createServer(
      {InternetAddress? address, int? port});
}
