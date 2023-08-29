import 'package:riverpod/riverpod.dart';

import 'mbps.dart';
import 'package:impulse/services/services.dart';

final uploadManagerProvider =
    StateNotifierProvider<UploadManager, (int, Item?)>((ref) {
  return UploadManager();
});

class UploadManager extends MBps with ServiceUploadManager {
  UploadManager() : super((0, null));

  ShareableItem? currentUpload;

  final List<ShareableItem> _uploads = <ShareableItem>[];
  List<ShareableItem> get uploads => _uploads;

  int numberOfDownloadedItems = 0;

  void addToQueue(Iterable<ShareableItem> newReceivabels) {
    for (var item in newReceivabels) {
      final contains = _uploads.map((e) => e.id).toList().contains(item.id);
      if (!contains) {
        _uploads.add(item);
      }
    }
  }

  void removeWhere(String id) {
    _uploads.removeWhere((element) => element.id == id);
  }

  @override
  void setCurrentUpload(Item? current) {
    currentUpload = current as ShareableItem;
    state = (previousMBps, currentUpload);
    currentUpload?.addListener(_listener);
  }

  @override
  void onCurrentUploadComplete() {
    currentUpload?.removeListener(_listener);
    removeWhere(currentUpload!.id);
    if (_uploads.isEmpty) {
      Future.delayed(const Duration(seconds: 1), () {
        state = (0, state.$2);
        cancelMbps();
      });
    }
  }

  void _listener(received, totalSize, file, reason, state) {
    DateTime now = DateTime.now();

    mbps(now, received, totalSize, file, reason, state);
  }

  void clear() {
    state = (0, null);
    currentUpload?.removeListener(_listener);
    currentUpload = null;
    _uploads.clear();
  }
}
