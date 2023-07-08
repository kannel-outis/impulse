import 'package:impulse/models/server_info.dart';

abstract class ServerManager {
  //TODO: should change to sync function later
  // Future<ServerInfo> get hostInfo;
  Future<ServerInfo> myServerInfo();
  List<String> getFiles();
  List<String> getPaths();
  set ipAddress(String? ipAddress);
  String? get ipAddress;
  set port(int? ipAddress);
  int? get port;

  //subject to removal later
  // ServerInfo? get clientServerInfo;
  Future<bool> handleClientServerNotification(Map<String, dynamic> serverMap) {
    throw UnimplementedError();
  }
}
