// ignore_for_file: unnecessary_getters_setters

import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/models/models.dart';
import 'package:impulse/services/services.dart';

final serverControllerProvider =
    ChangeNotifierProvider<ServerController>((ref) {
  final alert = ref.read(alertStateNotifier.notifier);
  final connectedUser = ref.read(connectUserStateProvider.notifier);
  final shareableProvider = ref.read(shareableItemsProvider.notifier);
  final uploadManager = ref.read(uploadManagerProvider.notifier);
  final sessionState = ref.read(currentSessionStateProvider.notifier);
  final connectedUserPreviousSessionState =
      ref.read(connectedUserPreviousSessionStateProvider.notifier);

  final serverController = ServerController(
    alertState: alert,
    connectedUserState: connectedUser,
    hiveManager: HiveManagerImpl.instance,
    shareableItemsProvider: shareableProvider,
    uploadManagerController: uploadManager,
    sessionStateN: sessionState,
    connectedUserPreviousSessionState: connectedUserPreviousSessionState,
  );
  ref.listen(
    connectionStateProvider,
    (previousState, newState) {
      serverController.connectionState = newState;
    },
  );
  ref.listen(currentSessionStateProvider, (previous, next) {
    serverController.sessionState = next;
  });
  ref.listen(connectedUserPreviousSessionStateProvider, (previous, next) {
    serverController.prevSessionState = next?.prevSession;
  });
  ref.listen(alertStateNotifier, (previous, next) {
    serverController.handleAlertResponse(next.alertResult);
  });
  return serverController;
});

class ServerController extends ServerManager with ChangeNotifier {
  final AlertState alertState;
  final ConnectedUserState connectedUserState;
  final SessionState sessionStateN;
  final HiveManager hiveManager;
  final ShareableItemsProvider shareableItemsProvider;
  final UploadManager uploadManagerController;
  final ConnectedUserPreviousSessionState connectedUserPreviousSessionState;

  ServerController({
    required this.alertState,
    required this.connectedUserState,
    required this.hiveManager,
    required this.shareableItemsProvider,
    required this.uploadManagerController,
    required this.sessionStateN,
    required this.connectedUserPreviousSessionState,
  });

  Completer<bool> alertResponder = Completer<bool>();
  // ignore: prefer_final_fields
  StreamController<Map<String, dynamic>> _receivableStreamController =
      StreamController<Map<String, dynamic>>();
  ConnectionState _connectionState = ConnectionState.notConnected;
  Session? _session;
  HiveSession? _prevSession;
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

  set connectionState(ConnectionState state) {
    _connectionState = state;
  }

  set sessionState(Session? session) {
    _session = session;
    log("currentSesion ::::${_session?.id}");
  }

  set prevSessionState(HiveSession? session) {
    _prevSession = session;
    log(" previos session::::${_prevSession?.previousSessionId}");
  }

  @override
  List<Item> getSelectedItems() {
    return uploadManagerController.uploads;
  }

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
      Map<String, dynamic> serverMap, Map<String, dynamic> sessionmap) async {
    try {
      if (_connectionState.isDisConnected) {
        alertResponder = Completer<bool>();
      }
      final shouldAcceptConnection =
          Configurations.instance.alwaysAcceptConnection;

      final requestUserServerInfo = ServerInfo.fromMap(serverMap);
      if (shouldAcceptConnection == false) {
        // alertState.shouldShowAlert(true);
        connectedUserState.setUserState(requestUserServerInfo, fling: true);

        /// so that users wont take too long
        _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
          handleAlertResponse(false);
        });
      } else {
        alertResponder.complete(true);
      }
      sessionStateN.setSession(Session.fromMap(sessionmap));

      ////
      final result = await alertResponder.future;
      if (result == false) {
        connectedUserState.setUserState(null);
        sessionStateN.cancelSession();
      } else {
        // connectedUserState.setUserState(requestUserServerInfo);

        ///The [Host] implementation. The [Client] implementation is in "receiver_controller.dart"
        ///At this point [requestUserServerInfo] is already connected
        ///we save a new session. not only do we save a new session but we check if
        ///we have connected to this user before. if we have it returns an existing [HiveSession]
        ///with an existing [Session] id and if we have not it saves a new [HiveSession] with a new [Session] id
        ///and returns it
        ///The [HiveSession] contains the info of the last [Session] id. the session when we
        ///last connect to this user.
        _prevSession = await hiveManager.saveSession(
          requestUserServerInfo.user.id,
          _session!.id,
        );
        // final session = Session(
        //   id: hiveSession.previousSessionId ?? _session!.id,
        //   usersOnSession: [myServerInfo.user, requestUserServerInfo.user],
        // );

        // _prevSession = prevSession;

        final nextSession = HiveSession(
          userId: _prevSession!.userId,
          previousSessionId: _session!.id,
          lastSessionDateTime: DateTime.now().toString(),
          previousSessionReceivable: [],
          previousSessionShareable: [],
        );
        await hiveManager.updateUserSession(nextSession);

        // prevSession;
        // nextSession.previousSessionId = _session!.id;
        // nextSession.lastSessionDateTime = DateTime.now().toIso8601String();
        // nextSession.previousSessionReceivable = [];
        // nextSession.previousSessionShareable = [];
        // nextSession.save();

        ///We create a [connectedUserPreviousSessionState] based on the info we got
        ///from the above operation
        ///
        ///
        ///create new instance so that we can easily throw an error if we try to use the hive save() function on it
        ///for debug reasons
        connectedUserPreviousSessionState.setUserPrevSession(
            _prevSession!.newInstance(), nextSession);
        connectedUserState.setUserState(requestUserServerInfo);
      }
      // _showAcceptDeclineAlert = false;
      return result;
    } catch (e, s) {
      sessionStateN.cancelSession();
      log(e.toString(), stackTrace: s);
      return false;
    }
  }

  void handleAlertResponse(bool response) async {
    alertResponder.complete(response);
    // alertState.shouldShowAlert(false);
    _timer?.cancel();
    alertResponder = Completer<bool>();
  }

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
      await hiveManager.saveItem(item, _session!.id);
      return hiveManager.getShareableItemWithKey(item.id)!;
    }
  }

  @override
  void removeCanceledItem(String id) {
    uploadManagerController.removeWhere(id);
    shareableItemsProvider.cancelItemWithId(id);
    hiveManager.removeItemWithKey(id);
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
  void continuePreviousDownloads() {
    // final s = _prevSession!.previousSessionShareable.map((e) => e.toMap());
    // for (var d in s) {
    //   log(d.toString());
    // }

    for (var prevItemId in _prevSession!.previousSessionShareable) {
      final prevItem = hiveManager.getShareableItemWithKey(prevItemId);
      final shareable = ShareableItem(
        file: File(prevItem!.path),
        fileType: prevItem.fileType,
        fileSize: prevItem.fileSize,
        id: prevItem.fileId,
        authorId: prevItem.authorId,
        altName: prevItem.fileName,
        homeDestination: (myServerInfo.ipAddress!, myServerInfo.port!),
      )..sentBytes = prevItem.processedBytes;
      if (!shareable.state.isCompleted) {
        log("$prevItemId ::::::::::::::::: shareable");
        shareableItemsProvider.addAllItems([shareable]);
        uploadManagerController.addToQueue([shareable]);
      }
    }
  }

  @override
  ServiceUploadManager get uploadManager => uploadManagerController;
}
