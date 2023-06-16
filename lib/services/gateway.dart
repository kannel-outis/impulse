import 'dart:io';

import 'package:flutter/foundation.dart';

abstract class GateWay<T extends Stream<K>, K extends Stream> {
  // final Function(K) listener;

  // GateWay(this.listener);
  const GateWay();
  Future<T> bind(InternetAddress address, int port);
  T? get server;

  @mustCallSuper
  // void listen() {
  //   server?.listen(listener);
  // }
  bool get isServerRunning => server != null;
  void listen();

  void close();

  void connect() {}

  InternetAddress get address;
  int get port;
}
