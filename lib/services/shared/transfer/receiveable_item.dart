import 'dart:io';

import 'package:impulse/services/services.dart';

class ReceiveableItem extends Item {
  final OnProgressCallBack? progressCallBack;
  final OnStateChange? stateChange;
  final int start;
  // final int fileLength;

  ReceiveableItem({
    required File file,
    required String fileType,
    required int fileSize,
    required String id,
    // required this.fileLength,
    this.start = 0,
    this.progressCallBack,
    this.stateChange,
    required (String, int) homeDestination,
    required String authorId,
  }) : super(
          id: id,
          file: file,
          fileSize: fileSize,
          authorId: authorId,
          fileType: fileType,
          onStateChange: stateChange,
          homeDestination: homeDestination,
          onProgressCallback: progressCallBack,
          fileName: file.path.split("/").last,
        );

  factory ReceiveableItem.fromShareableMap(Map<String, dynamic> map) {
    return ReceiveableItem(
      file: File("/storage/emulated/0/impulse/${map["fileName"] as String}"),
      fileType: map["fileType"] as String,
      fileSize: map["fileSize"] as int,
      id: map["fileId"] as String,
      homeDestination: (
        map["homeDestination"]["ip"] as String,
        map["homeDestination"]["port"] as int
      ),
      authorId: map["senderId"],
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

  void readyFileForDownload() {
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
    } else if (_downloadPaused) {
    } else {
      _downloadCanceled = true;
    }

    await _output.flush().then((value) {
      _output.close();
      _downloading = false;
      final totalBytes = downloadedBytes;
      // final contentSize = _contentSize(totalBytes);

      onStateChange?.call(totalBytes, fileSize, file, "", state);
    });
  }

  double get _progress => (downloadedBytes / fileSize) * 100;

  @override
  Future<void> receive() async {
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
      } else {
        await for (final data in stream) {
          downloadedBytes += data.length;
          // ignore: unused_local_variable
          final progress = _progress;
          if (_downloadCanceled || _downloadPaused) {
            return;
          }
          onProgressCallback?.call(
            downloadedBytes,
            fileSize,
            state,
          );
          _output.add(data);
        }
      }
      await _closeOutputStreams(true);
      return;
    } catch (e) {
      _downloading = false;
      _downloadFailed = true;
      onStateChange?.call(downloadedBytes, fileSize, file, e.toString(), state);
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

  DownloadState get state {
    if (_downloadCanceled) return DownloadState.canceled;
    if (_downloadCompleted) return DownloadState.completed;
    if (_downloadFailed) return DownloadState.failed;
    if (_downloading) return DownloadState.inProgress;
    if (_downloadPaused) return DownloadState.paused;
    return DownloadState.pending;
  }

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
