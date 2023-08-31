import 'package:equatable/equatable.dart';

// import 'session.dart';
import 'user.dart';

class ServerInfo extends Equatable {
  final User user;
  final String? ipAddress;
  final int? port;
  // final Session? session;

  const ServerInfo({
    required this.ipAddress,
    required this.port,
    required this.user,
    // this.session,
  });

  Map<String, dynamic> toMap() {
    return {
      "user": user.toFlingMap(),
      "ip": ipAddress,
      "port": port,
      // "session": session?.toMap(),
    };
  }

  factory ServerInfo.fromMap(Map<String, dynamic> map) {
    return ServerInfo(
      user: User.fromMap(map["user"] as Map<String, dynamic>),
      ipAddress: map["ip"],
      port: map["port"],
      // session: Session.fromMap(map["session"] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [
        user,
        ipAddress,
        port,
      ];
}
