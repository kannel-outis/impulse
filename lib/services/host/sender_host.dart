import 'package:dartz/dartz.dart';
import 'package:impulse/app/impulse_exception.dart';
import 'package:impulse/services/gateway.dart';

import '../client/client.dart';
import '../utils/services_utils.dart';
import 'host.dart';

class Sender implements Host, Client {
  // final Connection connection;
  final GateWay gateWay;

  Sender({required this.gateWay});
  @override
  Future<Either<AppException, String>> createServer({address, port}) async {
    print("object");
    return ServicesUtils.creatServer(
      gateWay: gateWay,
      address: address,
      port: port,
    );
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> establishConnectionToHost(
      {String? address, int? port}) {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> scan() async {
    return await ServicesUtils.scan();
  }
  
  @override
  Future<Either<AppException, Map<String, dynamic>>> makePostRequest({String? address, int? port}) {
    throw UnimplementedError();
  }
}
