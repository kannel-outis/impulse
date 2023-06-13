import 'dart:io';

import 'package:impulse/utils/constants.dart';

import 'client.dart';

class Sender implements Client {
  @override
  Future<List<String>> scan() async {
    final ipPrefix = _getIpPrefix("192.168.43.174");
    final availableServerAddress = <String>[];
    final List<Future<String?>> futures = <Future<String?>>[];
    for (var i = 1; i < 256; i++) {
      final ip = "$ipPrefix.$i";
      final result = _tryToEstablishConnection(ip);
      // if (result != null) {
      //   availableServerAddress.add(ip);
      //   print(result);
      // }
      futures.add(result);
    }

    await Future.wait(futures).then((value) {
      final result =
          List<String>.from(value.where((element) => element != null).toList());
      availableServerAddress.addAll(result);
      print(availableServerAddress);
    });

    return availableServerAddress;
  }

  String _getIpPrefix(String ip) {
    final splitList = ip.split(".");
    splitList.removeLast();
    return splitList.join(".");
  }

  Future<String?> _tryToEstablishConnection(String address) async {
    try {
      final socket = await Socket.connect(
        address,
        Constants.DEFAULT_PORT,
        timeout: const Duration(milliseconds: 500),
      );
      socket.close();
      return address;
    } catch (e) {
      return null;
    }
  }
}
