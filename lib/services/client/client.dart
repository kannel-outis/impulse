import 'package:dartz/dartz.dart';
import 'package:impulse/app/impulse_exception.dart';
import '../services.dart';

abstract class Client {
  Future<List<String>> scan() {
    throw UnimplementedError();
  }

  Future<Either<AppException, Map<String, dynamic>>> establishConnectionToHost(
      {required String address, int? port}) {
    throw UnimplementedError();
  }

  Future<Either<AppException, bool>> createServerAndNotifyHost(
      {required String address, int? port, required Map<String, dynamic> body});
}

abstract interface class ClientHost implements Client, Host {}
