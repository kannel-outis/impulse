import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:impulse/app/impulse_exception.dart';
import 'package:impulse/services/utils/request_helper.dart';
import 'package:impulse/services/gateway.dart';
import 'package:impulse/services/host/host.dart';
import 'package:impulse/services/utils/services_utils.dart';

import '../utils/constants.dart';
import 'client.dart';

class Receiver implements Client, Host {
  final GateWay? gateWay;

  Receiver({this.gateWay});
  static const int _port = Constants.DEFAULT_PORT;

  List<String> _ipAddresses = [];
  @override
  Future<List<String>> scan() async {
    final availableServerAddress = await ServicesUtils.scan();

    return _ipAddresses = availableServerAddress;
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> establishConnectionToHost(
      {String? address, int? port}) async {
    if (_ipAddresses.isEmpty) {
      return const Left(
        AppException("Cannot make a connection if no host is found"),
      );
    }
    final uri = Uri.parse(
        "http://${address ?? _ipAddresses.first}:${port ?? _port}/impulse/connect");
    return await RequestHelper.get(uri);
  }

  @override
  Future<Either<AppException, String>> createServer(
      {InternetAddress? address, int? port}) {
    if (gateWay == null) const AppException("This receiver is not a host");
    return ServicesUtils.creatServer(
      gateWay: gateWay!,
      address: address,
      port: port,
    );
  }
  
  @override
  Future<Either<AppException, Map<String, dynamic>>> makePostRequest({String? address, int? port}) {
    throw UnimplementedError();
  }
}
