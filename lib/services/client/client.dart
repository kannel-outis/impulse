import 'package:dartz/dartz.dart';
import 'package:impulse/app/impulse_exception.dart';

abstract class Client {
  Future<List<String>> scan() {
    throw UnimplementedError();
  }

  Future<Either<AppException, Map<String, dynamic>>> establishConnectionToHost(
      {String? address, int? port}) {
    throw UnimplementedError();
  }

  Future<Either<AppException, Map<String, dynamic>>> makePostRequest(
      {String? address, int? port, required Map<String, dynamic> body});
}
