// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import 'package:impulse/app/impulse_exception.dart';
import '../services.dart';

class ServicesUtils {
  static const serverRoutes = _ServerRoutes();
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

    final List<String?> futures = [];
    // final e = List.generate(255, (index) async {
    //   final ip = "$ipPrefix.$index";
    //   return await _tryToEstablishConnection(ip);
    // });
    for (var i = 0; i < 255; i++) {
      final ip = "$ipPrefix.$i";
      final s = await _tryToEstablishConnection(ip);
      futures.add(s);
    }

    // await Future.wait(futures).then((value) {
    //   final result =
    //       List<String>.from(value.where((element) => element != null).toList());
    //   availableServerAddress.addAll(result);
    //   availableServerAddress.removeWhere((element) => element == myIp.address);
    //   // ignore: avoid_print
    //   print(availableServerAddress);
    // });
    availableServerAddress.addAll(
        futures.where((element) => element != null).map((e) => e!).toList());
    availableServerAddress.removeWhere((element) => element == myIp.address);
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
        timeout: const Duration(milliseconds: 10),
      );
      socket.close();
      return address;
    } catch (e) {
      // log(e.toString());
      return null;
    }
  }

  static Stream<List<int>> getStream(String url,
      {Map<String, String>? headers,
      bool validate = true,
      int start = 0,
      required int end,
      Function(IClient)? init,
      int errorCount = 0}) async* {
    var client = http.Client();
    try {
      final request = http.Request('get', Uri.parse(url));

      request.headers[HttpHeaders.rangeHeader] = 'bytes=$start-${end - 1}';
      _defaultHeaders.forEach((key, value) {
        if (request.headers[key] == null) {
          request.headers[key] = _defaultHeaders[key]!;
        }
      });

      final response = await client.send(request);
      init?.call(
        IClient(client),
      );

      final stream = StreamController<List<int>>();
      response.stream.listen(
        (data) {
          stream.add(data);
        },
        onError: (_) => stream.close,
        onDone: stream.close,
        cancelOnError: false,
      );
      yield* stream.stream;
    } on Exception catch (e) {
      print(e.toString());
      client.close();
    }
    // }
    client.close();
  }

  static const Map<String, String> _defaultHeaders = {
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:68.0) Gecko/20100101 Firefox/68.0'
  };
}

class IClient {
  final http.Client client;
  IClient(this.client);
}

class _ServerRoutes {
  const _ServerRoutes();

  final connect = "impulse/connect";
  final download = "download";
  final client_server_info = "impulse/client_server_info";
  final shareables = "shareables";
  final shareables_more = "shareables/more";
  final continue_previous = "continue_previous";
  final cancel = "cancel";
}
