import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:impulse/utils/constants.dart';

import 'client.dart';

class Receiver implements Client {
  static const int _port = Constants.DEFAULT_PORT;

  List<String>? _ipAddresses;
  @override
  Future<List<String>> scan() async {
    final ipPrefix = _getIpPrefix("192.168.43.174");
    final availableServerAddress = <String>[];

    final List<Future<String?>> futures = List.generate(255, (index) {
      final ip = "$ipPrefix.$index";
      return _tryToEstablishConnection(ip);
    });

    await Future.wait(futures).then((value) {
      final result =
          List<String>.from(value.where((element) => element != null).toList());
      availableServerAddress.addAll(result);
      // ignore: avoid_print
      print(availableServerAddress);
    });

    return _ipAddresses = availableServerAddress;
  }

  @override
  Future<void> establishConnectionToHost({String? address, int? port}) async {
    final uri = Uri.parse(
        "http://${address ?? _ipAddresses!.first}:${port ?? _port}/impulse/connect");
    await http.get(uri).then(
      (value) {
        print(value.body);
      },
    );
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
        _port,
        timeout: const Duration(milliseconds: 500),
      );
      socket.close();
      return address;
    } catch (e) {
      return null;
    }
  }
}
