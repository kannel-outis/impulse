import 'dart:io';

import 'package:impulse/services/utils/enums.dart';

import 'item.dart';

class ReceiveableItem extends Item {
  final OnProgressCallBack? progressCallBack;
  final OnStateChange? stateChange;
  final (String, int) destination;
  final int start;
  final int fileLength;

  ReceiveableItem({
    required File file,
    required String fileType,
    required int fileSize,
    required String id,
    required this.fileLength,
    this.start = 0,
    this.progressCallBack,
    this.stateChange,
    required this.destination,
  }) : super(
          id: id,
          file: file,
          fileSize: fileSize,
          fileType: fileType,
          onProgressCallback: progressCallBack,
          onStateChange: stateChange,
        ) {
    _cleanPath();
    _output = file.openWrite(mode: FileMode.writeOnlyAppend);
  }

  late final IOSink _output;

  bool _downloadCanceled = false;
  bool _downloadCompleted = false;
  bool _downloadFailed = false;
  bool _downloading = false;
  bool _downloadPaused = false;

  int downloadedBytes = 0;

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

      onStateChange?.call(totalBytes, fileLength, file, "", state);
    });
  }

  @override
  Future<void> receive() {
    print("object");
    return super.receive();
  }

  DownloadState get state {
    if (_downloadCanceled) return DownloadState.canceled;
    if (_downloadCompleted) return DownloadState.completed;
    if (_downloadFailed) return DownloadState.failed;
    if (_downloading) return DownloadState.inProgress;
    if (_downloadPaused) return DownloadState.paused;
    return DownloadState.pending;
  }
}
