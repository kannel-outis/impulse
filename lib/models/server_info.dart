import 'package:equatable/equatable.dart';

import 'user.dart';

class ServerInfo extends Equatable {
  final User user;
  final String? ipAddress;
  final int? port;

  const ServerInfo({
    required this.ipAddress,
    required this.port,
    required this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      "user": user.toFlingMap(),
      "ip": ipAddress,
      "port": port,
    };
  }

  factory ServerInfo.fromMap(Map<String, dynamic> map) {
    return ServerInfo(
      user: User.fromMap(map["user"] as Map<String, dynamic>),
      ipAddress: map["ip"],
      port: map["port"],
    );
  }

  @override
  List<Object?> get props => [
        user,
        ipAddress,
        port,
      ];
}
