import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:impulse/app/impulse_exception.dart';
import 'package:impulse/app/utils/extensions.dart';
import '../services.dart';

class ServicesUtils {
  static Future<List<InternetAddress>> getAvailableIp() async {
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

  static Future<Either<AppException, (String, int)>> creatServer(
      {required GateWay gateWay, InternetAddress? address, int? port}) async {
    try {
      final ip = (await getAvailableIp()).random;
      await gateWay.bind(address ?? ip, port ?? Constants.DEFAULT_PORT);
      log("created server running on ${gateWay.address} and port ${gateWay.port}");
      gateWay.listen();
      return Right((ip.address, port ?? Constants.DEFAULT_PORT));
    } catch (_) {
      print(_.toString());
      return const Left(
        AppException(
            "Something went wrong. Cannot create server. Please connect to a network"),
      );
    }
  }

  static Future<List<String>> scan() async {
    final myIp = (await getAvailableIp()).random;
    final ipPrefix = _getIpPrefix(myIp.address);
    final availableServerAddress = <String>[];

    final List<Future<String?>> futures = List.generate(255, (index) {
      final ip = "$ipPrefix.$index";
      return _tryToEstablishConnection(ip);
    });

    await Future.wait(futures).then((value) {
      final result =
          List<String>.from(value.where((element) => element != null).toList());
      availableServerAddress.addAll(result);
      availableServerAddress.removeWhere((element) => element == myIp.address);
      // ignore: avoid_print
      print(availableServerAddress);
    });
    return availableServerAddress;
  }

  static String _getIpPrefix(String ip) {
    final splitList = ip.split(".");
    splitList.removeLast();
    return splitList.join(".");
  }

  static Future<String?> _tryToEstablishConnection(String address) async {
    try {
      final socket = await Socket.connect(
        address,
        Constants.DEFAULT_PORT /*_port*/,
        timeout: const Duration(milliseconds: 500),
      );
      socket.close();
      return address;
    } catch (e) {
      // log(e.toString());
      return null;
    }
  }
}
