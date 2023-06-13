import 'dart:io';

import 'package:flutter/material.dart';

abstract class GateWay<T extends Stream<K>, K extends Stream> {
  final Function(K) listener;

  GateWay(this.listener);
  Future<T> bind(dynamic address, int port);
  T? get server;

  @mustCallSuper
  void listen() {
    server?.listen(listener);
  }

  void close();

  void connect() {}

  InternetAddress get address;
  int get port;
}
