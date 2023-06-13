import 'package:dartz/dartz.dart';
import 'package:impulse/app/impulse_exception.dart';

abstract interface class Client {
  Future<List<String>> scan();
  Future<Either<AppException, Map<String, dynamic>>> establishConnectionToHost(
      {String? address, int? port});
}
