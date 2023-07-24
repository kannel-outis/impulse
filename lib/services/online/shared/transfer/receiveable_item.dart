// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:impulse/app/app.dart';
import 'package:impulse/services/services.dart';

class ReceiveableItem extends Item {
  // OnProgressCallBack? progressCallBack;
  // OnStateChange? stateChange;
  final int start;
  final String? altName;
  // final int fileLength;

  ReceiveableItem({
    required File file,
    required String fileType,
    required int fileSize,
    required String id,
    this.start = 0,
    // this.progressCallBack,
    // this.stateChange,
    required (String, int) homeDestination,
    required String authorId,
    this.altName,
  }) : super(
          id: id,
          file: file,
          fileSize: fileSize,
          authorId: authorId,
          fileType: fileType,
          // onStateChange: stateChange,
          homeDestination: homeDestination,
          // onProgressCallback: progressCallBack,
          fileName: file.path.split("/").last,
        );

  factory ReceiveableItem.fromShareableMap(Map<String, dynamic> map) {
    final fileName = map["altName"] != null
        ? _joinNameWithId(
            "${map["altName"] as String}.${map["fileType"] as String}",
            map["fileId"] as String)
        : _joinNameWithId(
            "${map["fileName"] as String}}", map["fileId"] as String);
    return ReceiveableItem(
      file: File("${Configurations.instance.impulseDir.path}$fileName"),
      fileType: map["fileType"] as String,
      fileSize: map["fileSize"] as int,
      id: map["fileId"] as String,
      altName: map["altName"],
      homeDestination: (
        map["homeDestination"]["ip"] as String,
        map["homeDestination"]["port"] as int
      ),
      authorId: map["senderId"],
    );
  }

  static String _joinNameWithId(String name, String id) {
    ///Storing with individual ids to avoid problems with app or file with the same name,
    final list = (name).split(".");
    list.insert(1, id);
    return list.join(".");
  }

  ReceiveableItem copyWith({
    File? file,
    int? start,
  }) {
    return ReceiveableItem(
      file: file ?? this.file,
      fileType: fileType,
      fileSize: fileSize,
      id: id,
      homeDestination: homeDestination,
      authorId: authorId,
      // progressCallBack: progressCallBack,
      // stateChange: stateChange,
      start: start ?? this.start,
    );
  }

  late final Client _client = ClientImpl();

  late final IOSink _output;
  late final IClient _iClient;

  bool _downloadCanceled = false;
  bool _downloadCompleted = false;
  bool _downloadFailed = false;
  bool _downloading = false;
  bool _downloadPaused = false;

  int downloadedBytes = 0;

  void _readyFileForDownload() {
    _cleanPath();
    _output = file.openWrite(mode: FileMode.writeOnlyAppend);
  }

  void _cleanPath() {
    if (start == 0 && file.existsSync()) {
      file.deleteSync();
    }
  }

  Future<void> _closeOutputStreams([bool complete = false]) async {
    if (complete) {
      _downloadCompleted = complete;
      // onProgressCallback?.call(
      //   downloadedBytes,
      //   fileSize,
      //   state,
      // );
      notifyListeners(downloadedBytes, fileSize, file, "", state);
    } else if (_downloadPaused) {
    } else {
      _downloadCanceled = true;
    }

    await _output.flush().then((value) {
      _output.close();
      _downloading = false;
      final totalBytes = downloadedBytes;
      // final contentSize = _contentSize(totalBytes);

      // onStateChange?.call(totalBytes, fileSize, file, "", state);
      notifyListeners(totalBytes, fileSize, file, "", state);
    });
    startTime = null;
  }

  double get _progress => (downloadedBytes / fileSize) * 100;

  @override
  Future<void> receive() async {
    // log(id.toString());
    // return;
    startTime = DateTime.now();
    _readyFileForDownload();
    _downloadPaused = false;
    try {
      downloadedBytes = start;
      final stream = _client.getFileStreamFromHostServer(homeDestination, id,
          start: start, end: fileSize, init: (length, client) {
        _iClient = client;
      });
      _downloading = true;
      final streamSize = fileSize;

      if (downloadedBytes >= streamSize) {
        /////does nothing
      } else {
        await for (final data in stream) {
          downloadedBytes += data.length;
          // ignore: unused_local_variable
          final progress = _progress;
          if (_downloadCanceled || _downloadPaused) {
            return;
          }
          // onProgressCallback?.call(
          //   downloadedBytes,
          //   fileSize,
          //   state,
          // );
          notifyListeners(downloadedBytes, fileSize, file, "", state);
          _output.add(data);
        }

        ///After successful download update the state once more and call the onProgress
        ///the completed state can also be gotten from the onStateChange callback
        // onProgressCallback?.call(
        //   downloadedBytes,
        //   fileSize,
        //   IState.completed,
        // );
      }
      print(downloadedBytes);
      await _closeOutputStreams(true);
      return;
    } catch (e) {
      _downloading = false;
      _downloadFailed = true;
      // onStateChange?.call(downloadedBytes, fileSize, file, e.toString(), state);
      notifyListeners(downloadedBytes, fileSize, file, e.toString(), state);
      return;
    }
  }

  @override
  Future<void> pause() async {
    _downloadPaused = true;
    await _closeOutputStreams().then(
      (value) => _iClient.client.close(),
    );
  }

  @override
  Future<void> cancel() async {
    await _closeOutputStreams().then((value) {
      file.deleteSync();
      _iClient.client.close();
    });
  }

  @override
  IState get state {
    if (_downloadCanceled) return IState.canceled;
    if (_downloadCompleted) return IState.completed;
    if (_downloadFailed) return IState.failed;
    if (_downloading) return IState.inProgress;
    if (_downloadPaused) return IState.paused;
    return IState.pending;
  }

  @override
  int get proccessedBytes => downloadedBytes;

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }

  @override
  List<Object?> get props => [
        fileSize,
        fileType,
        id,
        fileName,
        authorId,
        filePath,
      ];
}
