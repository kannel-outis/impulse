import 'dart:io';

import 'package:impulse/services/gateway.dart';

import 'user.dart';

class Connection {
  final GateWay gateWay;
  final List<User> usersOnNetwork;
  final String hostId;

  Connection({
    required this.gateWay,
    required this.usersOnNetwork,
    required this.hostId,
  });
}

