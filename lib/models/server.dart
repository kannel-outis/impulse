import 'package:flutter/material.dart';

abstract class Server<T extends Stream<K>, K extends Stream> {
  final Function(K) listener;

  Server(this.listener);
  Future<T> bind(dynamic address, int port);
  T get gateWay;

  @mustCallSuper
  void listen() {
    gateWay.listen(listener);
  }
}
