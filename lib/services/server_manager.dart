import 'package:impulse/models/user.dart';

abstract interface class ServerManager {
  //TODO: should change to sync function later
  Future<User> get hostInfo;
  List<String> getFiles();
  List<String> getPaths();
}
