import 'dart:io';

import 'package:impulse/services/services.dart';
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

  double get _progress => (downloadedBytes / fileLength) * 100;

  @override
  Future<void> receive() async {
    _downloadPaused = false;
    try {
      downloadedBytes = start;
      final stream =
          ServicesUtils.getStream(destination, start: start, end: fileLength);
      _downloading = true;
      final streamSize = fileLength;

      if (downloadedBytes >= streamSize) {
      } else {
        await for (final data in stream) {
          downloadedBytes += data.length;
          final progress = _progress;
          if (_downloadCanceled || _downloadPaused) {
            return;
          }
          onProgressCallback?.call(
            downloadedBytes,
            fileLength,
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
      onStateChange?.call(
          downloadedBytes, fileLength, file, e.toString(), state);
      return;
    }
  }

  @override
  Future<void> pause() async {
    _downloadPaused = true;
    await _closeOutputStreams();
  }

  @override
  Future<void> cancel() async {
    await _closeOutputStreams().then((value) {
      file.deleteSync();
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
}
