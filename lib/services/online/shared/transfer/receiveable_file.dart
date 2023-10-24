part of 'receiveable_item.dart';

class _ReceiveableFile extends ReceiveableItem {
  _ReceiveableFile({
    String? altName,
    required String authorId,
    required File file,
    required int fileSize,
    required String fileType,
    required (String, int) homeDestination,
    required String id,
  }) : super(
          authorId: authorId,
          file: file,
          fileSize: fileSize,
          fileType: fileType,
          homeDestination: homeDestination,
          id: id,
          altName: altName,
        ) {
    _downloadedBytes = start;
  }

  late final Client _client = ClientImpl();

  IOSink? _output;
  IClient? _iClient;

  bool _downloadCanceled = false;
  bool _downloadCompleted = false;
  bool _downloadFailed = false;
  bool _downloading = false;
  bool _downloadPaused = false;

  int _downloadedBytes = 0;

  void _readyFileForDownload() {
    _cleanPath();
    _output = (file as File).openWrite(mode: FileMode.writeOnlyAppend);
  }

  void _cleanPath() {
    if (start == 0 && file.existsSync()) {
      file.deleteSync();
    }
  }

  Future<void> _closeOutputStreams([bool complete = false]) async {
    if (complete) {
      _downloadCompleted = complete;

      notifyListeners(_downloadedBytes, fileSize, file, "", state);
    } else if (_downloadPaused) {
      _downloadCanceled = false;
      _downloadFailed = false;
      _downloadCompleted = false;
    } else if (_downloadCanceled) {
      _downloadPaused = false;
      _downloadFailed = false;
      _downloadCompleted = false;
    } else {
      _downloadFailed = true;
    }

    await _output?.flush().then((value) {
      _output?.close();
      _downloading = false;
      final totalBytes = _downloadedBytes;

      notifyListeners(totalBytes, fileSize, file, "", state);
    });
    startTime = null;
  }

  double get _progress => (_downloadedBytes / fileSize) * 100;

  @override
  Future<void> receive() async {
    startTime = DateTime.now();
    _readyFileForDownload();
    _downloadPaused = false;
    try {
      _downloadedBytes = start;
      final stream = _client.getFileStreamFromHostServer(homeDestination!, id,
          start: start, end: fileSize, init: (client) {
        _iClient = client;
      });
      _downloading = true;
      final streamSize = fileSize;

      if (_downloadedBytes >= streamSize) {
        /////does nothing
      } else {
        await for (final data in stream) {
          // ignore: unused_local_variable
          final progress = _progress;
          if (_downloadCanceled || _downloadPaused) {
            _iClient?.client.close();

            return;
          }
          _downloadedBytes += data.length;

          notifyListeners(_downloadedBytes, fileSize, file, "", state);
          _output?.add(data);
        }

        ///After successful download update the state once more and call the onProgress
        ///the completed state can also be gotten from the onStateChange callback
      }
      log(_downloadedBytes.toString());
      await _closeOutputStreams(_downloadedBytes == fileSize ? true : false);
      return;
    } catch (e) {
      _downloading = false;
      _downloadFailed = true;

      await _closeOutputStreams();
      notifyListeners(_downloadedBytes, fileSize, file, e.toString(), state);
      return;
    }
  }

  @override
  Future<void> pause() async {
    _downloadPaused = true;
    await _closeOutputStreams().then(
      (value) => _iClient?.client.close(),
    );
  }

  @override
  Future<void> cancel() async {
    _downloadCanceled = true;
    await _closeOutputStreams().then((value) async {
      await file.delete();
      _iClient?.client.close();
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
  int get proccessedBytes => _downloadedBytes;

  @override
  void changeState(IState newState) {
    notifyListeners(
        _downloadedBytes, fileSize, file, "Queue from pause", newState);
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
