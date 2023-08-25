import 'dart:async';
import 'dart:io';

import 'package:impulse/models/server_info.dart';
import 'package:impulse/services/services.dart';

abstract class ServerManager {
  ///upload manager for
  ServiceUploadManager get uploadManager;

  ///This servers information
  ServerInfo get myServerInfo;

  ///set selected shareableitems
  // void setSelectedItems(List<Item> items);

  ///get selected shareableitems
  List<Item> getSelectedItems();
  // List<String> getPaths();

  ///set and get the ip address and port that makes up the serverinfo above
  set ipAddress(String? ipAddress);
  String? get ipAddress;
  set port(int? ipAddress);
  int? get port;

  ///Gets a local version of a shareableitem and creates one if it does not exist
  Future<HiveItem> getHiveItemForShareable(Item item);

  ///Removes Canceled download from shareableitems list
  void removeCanceledItem(String id);

  ///When a connection is first attempted, A notification is sent to the host,
  ///The host can decide whetther to accept or decline
  ///This just returns the result of that.
  Future<bool> handleClientServerNotification(Map<String, dynamic> serverMap) {
    throw UnimplementedError();
  }

  ///This returns the hosts files as map, which eventually becomes a network file on the client side
  Future<List<Map<String, dynamic>>> getEntitiesInDir(String path,
      [Function()? _]);

  Future<List<FileSystemEntity>> getEntities(Directory dir) async {
    final listSync = <FileSystemEntity>[];

    await for (final entity in dir.list()) {
      listSync.add(entity);
    }
    return listSync;
  }

  /// adds Client File Request To ShareableItemsList
  void addSharableToList(Map<String, dynamic> shareableMap) {}

  StreamController<Map<String, dynamic>> get receivablesStreamController;
}
