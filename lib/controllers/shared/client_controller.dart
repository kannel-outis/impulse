import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:impulse/app/impulse_exception.dart';
import 'package:impulse/services/services.dart';

class ClientProvider extends ChangeNotifier {
  final Client client;

  ClientProvider({required this.client});

  String? _address;
  String? get address => _address;
  int? _port;
  int? get port => _port;
  List<String> _availableIps = [];

  ///The client can be used as host here because it implements the [Host] abtract class
  ///This function will be called after a successful scan and an available host has be selected
  ///That way we can be sure of two things. 1) a host has been found/selected, 2) The selected host has already occupied the default port ----
  /// --- Thats the green light we need to use the second port.
  Future<AppException?> createServer({
    dynamic address,
    int? port,
    Function(AppException)? onErrorCallback,
  }) async {
    if (client is! ClientHost) {
      const exception = AppException("This client cannot host a server");
      onErrorCallback?.call(exception);
      return exception;
    }
    final result =
        await (client as Host).createServer(address: address, port: port);
    if (result is Left) {
      final exception = (result as Left).value as AppException;
      onErrorCallback?.call(exception);
      return exception;
    } else {
      final addressAndPort = (result as Right).value as (String, int);
      _address = addressAndPort.$1;
      _port = addressAndPort.$2;
      notifyListeners();
      return null;
    }
  }

  Future<void> _scan() async {
    final list = await client.scan();
    _availableIps = list;
    notifyListeners();
  }

  // Future<void>
}
