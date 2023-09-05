import 'package:dartz/dartz.dart';
import 'package:impulse/app/impulse_exception.dart';
import '../../services.dart';

abstract class Client {
  Future<List<String>> scan() {
    throw UnimplementedError();
  }

  Future<Either<AppException, Map<String, dynamic>>> establishConnectionToHost(
      {required String address, int? port}) {
    throw UnimplementedError();
  }

  Future<Either<AppException, bool>> createServerAndNotifyHost(
      {required String address,
      int? port,
      required Map<String, dynamic> serverInfo,
      required Map<String, dynamic> sessionInfo});

  Stream<List<int>> getFileStreamFromHostServer(
    (String, int) destination,
    String fileId, {
    Map<String, String>? headers,
    int start = 0,
    required int end,
    Function(IClient)? init,
  });

  Future<void> cancelItem(
    (String, int) destination,
    String fileId,
  );

  Future<Either<AppException?, List<Map<String, dynamic>>>> getNetworkFiles(
      String path, (String, int) destination);
  Future<Either<AppException?, Map<String, dynamic>>>
      addMoreShareablesOnHostServer(
          Map<String, dynamic> shareableItemMap, (String, int) destination);
  Future<Either<AppException, Map<String, dynamic>>> continuePreviousDownloads(
      (String, int) destination);
}

abstract interface class ClientHost implements Client, Host {}
