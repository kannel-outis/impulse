import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:impulse/app/impulse_exception.dart';
import 'package:impulse/services/gateway.dart';
import 'package:impulse/app/utils/constants.dart';
import 'package:impulse/app/utils/extensions.dart';

import 'host.dart';

class Sender implements Host {
  // final Connection connection;
  final GateWay gateWay;

  Sender({required this.gateWay});
  @override
  Future<Either<AppException, String>> createServer({address, port}) async {
    // return;
    try {
      final ip = (await _getAvailableIp()).random;
      await gateWay.bind(ip, port ?? Constants.DEFAULT_PORT);
      print(
          "created server running on ${gateWay.address} and port ${gateWay.port}");
      gateWay.listen();
      return Right(ip.address);
    } catch (_) {
      return Left(AppException(_.toString()));
    }
  }

  Future<List<InternetAddress>> _getAvailableIp() async {
    final usableIps = <InternetAddress>[];
    final availableAddresses =
        await NetworkInterface.list(type: InternetAddressType.IPv4);
    final listOfIpAddress = availableAddresses.map((e) => e.addresses).toList();
    for (var address in listOfIpAddress) {
      for (var a in address) {
        if (a.address.contains("192.168")) {
          usableIps.add(a);
        }
      }
    }
    return usableIps;
  }
}
