import 'package:riverpod/riverpod.dart';

import 'mbps.dart';
import 'package:impulse/services/services.dart';

final uploadManagerProvider = StateNotifierProvider<UploadManager,
    ({int mBps, Item? currentDownload, Duration remainingTime})>((ref) {
  return UploadManager();
});

class UploadManager extends MBps with ServiceUploadManager {
  UploadManager()
      : super((
          mBps: 0,
          currentDownload: null,
          remainingTime: const Duration(),
        ));

  ShareableItem? currentUpload;

  final List<ShareableItem> _uploads = <ShareableItem>[];
  List<ShareableItem> get uploads => _uploads;

  int numberOfDownloadedItems = 0;

  void addToQueue(Iterable<ShareableItem> newReceivabels) {
    // if (_uploads.isEmpty) overallStartTime = DateTime.now();
    for (var item in newReceivabels) {
      final contains = _uploads.map((e) => e.id).toList().contains(item.id);
      if (!contains) {
        _uploads.add(item);
        totalDownloadSize = totalDownloadSize + item.remainingBytes;
      }
    }
  }

  void removeWhere(String id) {
    _uploads.removeWhere((element) {
      // totalDownloadSize = totalDownloadSize - element.fileSize;
      return element.id == id;
    });
  }

  @override
  void setCurrentUpload(Item? current) {
    currentUpload = current as ShareableItem;
    state = (
      mBps: previousMBps,
      currentDownload: currentUpload,
      remainingTime: state.remainingTime,
    );
    currentUpload?.addListener(_listener);
  }

  @override
  void onCurrentUploadComplete(int downloadedSize) {
    currentUpload?.removeListener(_listener);
    if (downloadedSize == currentUpload!.fileSize) {
      removeWhere(currentUpload!.id);
    }
    if (_uploads.isEmpty) {
      Future.delayed(const Duration(seconds: 1), () {
        state = (
          mBps: 0,
          currentDownload: state.currentDownload,
          remainingTime: const Duration(),
        );
        cancelMbps();
      });
    }
  }

  void _listener(received, totalSize, file, reason, state) {
    DateTime now = DateTime.now();

    mbps(now, received, totalSize, file, reason, state);
  }

  void clear() {
    state = (
      mBps: 0,
      currentDownload: null,
      remainingTime: const Duration(),
    );
    currentUpload?.removeListener(_listener);
    currentUpload = null;
    _uploads.clear();
  }
}
