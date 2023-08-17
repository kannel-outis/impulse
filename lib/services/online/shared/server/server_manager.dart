import 'dart:async';
import 'dart:io';

import 'package:impulse/models/server_info.dart';
import 'package:impulse/services/services.dart';
import 'package:impulse_utils/impulse_utils.dart';

abstract class ServerManager {
  //TODO: should change to sync function later
  // Future<ServerInfo> get hostInfo;
  ServerInfo get myServerInfo;
  void setSelectedItems(List<Item> items);
  List<Item> getSelectedItems();
  List<String> getPaths();
  set ipAddress(String? ipAddress);
  String? get ipAddress;
  set port(int? ipAddress);
  int? get port;
  Future<HiveItem> getHiveItemForShareable(Item item);
  void removeCanceledItem(String id);

  //subject to removal later
  // ServerInfo? get clientServerInfo;
  Future<bool> handleClientServerNotification(Map<String, dynamic> serverMap) {
    throw UnimplementedError();
  }

  Future<List<Map<String, dynamic>>> getEntitiesInDir(String path,
      [Function()? _]);

  Future<List<FileSystemEntity>> getEntities(Directory dir) async {
    final listSync = <FileSystemEntity>[];

    await for (final entity in dir.list()) {
      listSync.add(entity);
    }
    return listSync;
  }

  StreamController<Map<String, dynamic>> get receivablesStreamController;
}
