import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:impulse/app/impulse_exception.dart';
import 'package:impulse/services/services.dart';

class HostProvider extends ChangeNotifier {
  final Host host;
  HostProvider({required this.host});

  String? address;
  int? port;

  Future<AppException?> createServer({
    dynamic address,
    int? port,
    Function(AppException)? onErrorCallback,
  }) async {
    final result = await host.createServer(address: address, port: port);
    if (result is Left) {
      final exception = (result as Left).value as AppException;
      onErrorCallback?.call(exception);
      return exception;
    } else {
      final addressAndPort = (result as Right).value as (String, int);
      this.address = addressAndPort.$1;
      this.port = addressAndPort.$2;
      notifyListeners();
      return null;
    }
  }
}
