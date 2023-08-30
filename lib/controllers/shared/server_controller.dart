// ignore_for_file: unnecessary_getters_setters

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/models/network_impulse_file.dart';
import 'package:impulse/models/server_info.dart';
import 'package:impulse/services/services.dart';

final serverControllerProvider =
    ChangeNotifierProvider<ServerController>((ref) {
  final alert = ref.watch(alertStateNotifier.notifier);
  final connectedUser = ref.watch(connectUserStateProvider.notifier);
  final shareableProvider = ref.read(shareableItemsProvider.notifier);
  final uploadManager = ref.watch(uploadManagerProvider.notifier);
  return ServerController(
    alertState: alert,
    connectedUserState: connectedUser,
    hiveManager: HiveManagerImpl(),
    shareableItemsProvider: shareableProvider,
    uploadManagerController: uploadManager,
  );
});

class ServerController extends ServerManager with ChangeNotifier {
  final AlertState alertState;
  final ConnectedUserState connectedUserState;
  final HiveManager hiveManager;
  final ShareableItemsProvider shareableItemsProvider;
  final UploadManager uploadManagerController;

  ServerController({
    required this.alertState,
    required this.connectedUserState,
    required this.hiveManager,
    required this.shareableItemsProvider,
    required this.uploadManagerController,
  });

  Completer<bool> alertResponder = Completer<bool>();
  final StreamController<Map<String, dynamic>> _receivableStreamController =
      StreamController<Map<String, dynamic>>();
  Timer? _timer;
  // List<Item> _items = [];

  /////
  /// The Senders/Hosts ip address and port that needs to be set after server creation
  String? _ipAddress;
  @override
  String? get ipAddress => _ipAddress;
  @override
  set ipAddress(String? ip) {
    _ipAddress = ip;
  }

  int? _port;
  @override
  int? get port => _port;
  @override
  set port(int? port) {
    _port = port;
  }

  ///This is called everytime we select an file or item
  ///cleed from [SelectedItems] provider
  // @override
  // void setSelectedItems(List<Item> items) {
  //   _items = items;
  // }

  @override
  List<Item> getSelectedItems() {
    return uploadManagerController.uploads;
  }

  // @override
  // List<String> getPaths() {
  //   return <String>[];
  // }

  @override
  ServerInfo get myServerInfo {
    final me = Configurations.instance.user!.copyWith(
      ipAddress: _ipAddress,
      port: _port,
    );
    return ServerInfo(
      user: me,
      ipAddress: _ipAddress,
      port: _port,
    );
  }

  @override
  Future<bool> handleClientServerNotification(
      Map<String, dynamic> serverMap) async {
    try {
      // ignore: todo
      //TODO: remove alertstate entirely and use connectedUserState.setUserState(serverInfo, fling: true)
      // to show alert instead
      // if (connectionState.isDisConnected) {
      //   alertResponder = Completer<bool>();
      // }

      final shouldAcceptConnection =
          Configurations.instance.alwaysAcceptConnection;

      final serverInfo = ServerInfo.fromMap(serverMap);
      if (shouldAcceptConnection == false) {
        alertState.updateState(true);
        connectedUserState.setUserState(serverInfo, fling: true);

        /// so that users wont take too long
        _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
          handleAlertResponse(false);
        });
      } else {
        alertResponder.complete(true);
      }

      ////
      final result = await alertResponder.future;
      if (result == false) {
        connectedUserState.setUserState(null);
      } else {
        connectedUserState.setUserState(serverInfo);
      }
      // _showAcceptDeclineAlert = false;
      return result;
    } catch (e) {
      return false;
    }
  }

  void handleAlertResponse(bool response) async {
    alertResponder.complete(response);
    alertState.updateState(false);
    _timer?.cancel();
    alertResponder = Completer<bool>();
  }

  // void reset() {
  //   _receivableStreamController = StreamController<Map<String, dynamic>>();
  // }

  @override
  StreamController<Map<String, dynamic>> get receivablesStreamController =>
      _receivableStreamController;

  void addToReceivableStream(Map<String, dynamic> map) {
    _receivableStreamController.add(map);
  }

  @override
  Future<HiveItem> getHiveItemForShareable(Item item) async {
    final hiveItem = hiveManager.getShareableItemWithKey(item.id);
    if (hiveItem != null) {
      return hiveItem;
    } else {
      await hiveManager.saveItem(item);
      return hiveManager.getShareableItemWithKey(item.id)!;
    }
  }

  @override
  void removeCanceledItem(String id) {
    // _items.removeWhere((element) => element.id == id);
    uploadManagerController.removeWhere(id);
    shareableItemsProvider.cancelItemWithId(id);
  }

  @override
  Future<(String?, List<Map<String, dynamic>>)> getEntitiesInDir(String path,
      [Function(String?)? _]) async {
    final directoryToMap = <Map<String, dynamic>>[];
    final fileToMap = <Map<String, dynamic>>[];

    final dir = path == "root" ? _getRootDir : Directory(path);
    if (!await dir.exists() ||
        Platform.isIOS ||
        !Configurations.instance.allowToBrowseFile) {
      return (
        !Configurations.instance.allowToBrowseFile
            ? "Permission denied"
            : "Directory Not Found",
        <Map<String, dynamic>>[]
      );
    }

    final listAsync = await getEntities(dir);

    listAsync
        .sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    for (var item in listAsync) {
      final file = NetworkImpulseFileEntity(
        isFolder: item is Directory,
        modified: item.statSync().modified,
        name: item.path.split(Platform.pathSeparator).last,
        serverInfo: myServerInfo,
        path: item.path,
        size: item.statSync().size,
      );

      item is Directory
          ? directoryToMap.add(file.toMap())
          : fileToMap.add(file.toMap());
    }

    return (null, [...directoryToMap, ...fileToMap]);
  }

  Directory get _getRootDir {
    if (Platform.isAndroid) {
      return Directory(Configurations.instance.fileManager.rootPath.first);
    } else {
      return Configurations.instance.impulseDir!;
    }
  }

  @override
  void addSharableToList(Map<String, dynamic> shareableMap) {
    final shareableItem = ShareableItem.fromMap(shareableMap);
    shareableItemsProvider.addAllItems([shareableItem]);

    ///TODO: move into shareableItemsProvider
    uploadManagerController.addToQueue([shareableItem]);
  }

  @override
  ServiceUploadManager get uploadManager => uploadManagerController;
}
