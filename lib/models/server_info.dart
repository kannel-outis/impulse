import 'user.dart';

class ServerInfo {
  final User user;
  String? ipAddress;
  int? port;

  ServerInfo({
    this.ipAddress,
    this.port,
    required this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      "user": user.toMap(),
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
}
