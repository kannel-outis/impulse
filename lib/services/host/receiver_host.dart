import 'dart:io';

import 'package:impulse/services/gateway.dart';
import 'package:impulse/utils/constants.dart';
import 'package:impulse/utils/extensions.dart';

import 'host.dart';

class Receiver implements Host {
  // final Connection connection;
  final GateWay gateWay;

  Receiver({required this.gateWay});
  @override
  Future<void> createServer({address, port}) async {
    // return;
    try {
      final ip = await _getAvailableIp();
      await gateWay.bind(ip, port ?? Constants.DEFAULT_PORT);
      print(
          "created server running on ${gateWay.address} and port ${gateWay.port}");
      gateWay.listen();
    } catch (_) {
      print(_.toString());
    }
  }

  @override
  Future<List<InternetAddress>> scan() {
    // TODO: implement scan
    throw UnimplementedError();
  }

  // @override
  // Future<List<InternetAddress>> scan() async{
  //   final
  // }

  Future<InternetAddress> _getAvailableIp() async {
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
    return usableIps.random;
  }
}
