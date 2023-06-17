import 'package:dartz/dartz.dart';
import 'package:impulse/app/impulse_exception.dart';
import 'package:impulse/services/gateway.dart';

import '../client/client.dart';
import '../utils/services_utils.dart';
import 'host.dart';

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
}
